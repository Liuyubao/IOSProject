//
//  SportsIndexVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/10/23.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit
import SwiftCharts
import CoreMotion

class SportsIndexVC: UIViewController {
    //计步器对象
    let pedometer = CMPedometer()
    
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var progressView: OProgressView2!
    
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //开始计步器更新
        startPedometerUpdates()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.progressView.setProgress(0, animated: false)
    }
    
    
    fileprivate var chart: Chart?
    let sideSelectorHeight: CGFloat = 50
    
    fileprivate func barsChart(horizontal: Bool) -> Chart {
        let tuplesXY = [(12, 8000), (13, 9000), (14, 10000), (15, 1200), (16, 17000), (17, 15000), (18, 13000)]
        
        func reverseTuples(_ tuples: [(Int, Int)]) -> [(Int, Int)] {
            return tuples.map{($0.1, $0.0)}
        }
        
        let chartPoints = (horizontal ? reverseTuples(tuplesXY) : tuplesXY).map{ChartPoint(x: ChartAxisValueInt($0.0), y: ChartAxisValueInt($0.1))}
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let generator = ChartAxisGeneratorMultiplier(1)
        let labelsGenerator = ChartAxisLabelsGeneratorFunc {scalar in
            return ChartAxisLabel(text: "10.\(Int(scalar))", settings: labelSettings)
        }
        let xGenerator = ChartAxisGeneratorMultiplier(1)
        
        let xModel = ChartAxisModel(firstModelValue: 12, lastModelValue: 18, axisTitleLabels: [ChartAxisLabel(text: "", settings: labelSettings)], axisValuesGenerator: xGenerator, labelsGenerator: labelsGenerator)
        let yModel = ChartAxisModel(firstModelValue: 0, lastModelValue: 20000, axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical())], axisValuesGenerator: generator, labelsGenerator: labelsGenerator)
        
        let barViewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsViewsLayer, chart: Chart) -> UIView? in
            let bottomLeft = CGPoint(x:0, y: self.barView.height)
            
            let barWidth: CGFloat = 2.5
            
            let settings = ChartBarViewSettings(animDuration: 0.5)
            
            let (p1, p2): (CGPoint, CGPoint) = {
                if horizontal {
                    return (CGPoint(x: bottomLeft.x, y: chartPointModel.screenLoc.y), CGPoint(x: chartPointModel.screenLoc.x, y: chartPointModel.screenLoc.y))
                } else {
                    return (CGPoint(x: chartPointModel.screenLoc.x, y: bottomLeft.y), CGPoint(x: chartPointModel.screenLoc.x, y: chartPointModel.screenLoc.y))
                }
            }()
            let tempColor = UIColor(red: 208.0 / 255.0, green: 255.0 / 255.0, blue: 45.0 / 255.0, alpha: 0.6)
            return ChartPointViewBar(p1: p1, p2: p2, width: barWidth, bgColor: tempColor, settings: settings)
        }
        
//        let frame = ExamplesDefaults.chartFrame(self.barView.bounds)
        let chartFrame = chart?.frame ?? CGRect(x: -10, y: 0, width: self.barView.width, height: self.barView.height)
        
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let chartPointsLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints, viewGenerator: barViewGenerator)
        
//        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.black, linesWidth: ExamplesDefaults.guidelinesWidth)
//        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: settings)
        
        return Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                chartPointsLayer
            ]
        )
    }
    
    fileprivate func showChart(horizontal: Bool) {
        self.chart?.clearView()
        
        let chart = barsChart(horizontal: horizontal)
        view.addSubview(chart.view)
        self.chart = chart
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 开始获取步数计数据
    func startPedometerUpdates() {
        //判断设备支持情况
        guard CMPedometer.isStepCountingAvailable() else {
            "\n当前设备不支持获取步数\n".ext_debugPrintAndHint()
            return
        }
        
        //获取今天凌晨时间
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        let midnightOfToday = cal.date(from: comps)!
        
        //初始化并开始实时获取数据
        self.pedometer.startUpdates (from: midnightOfToday, withHandler: { pedometerData, error in
            //错误处理
            guard error == nil else {
                print(error!)
                return
            }
            
            //获取各个数据
            var text = "---今日运动数据---\n"
            if let numberOfSteps = pedometerData?.numberOfSteps {
                text += "步数: \(numberOfSteps)\n"
            }
            if let distance = pedometerData?.distance {
                text += "距离: \(distance)\n"
            }
            if let floorsAscended = pedometerData?.floorsAscended {
                text += "上楼: \(floorsAscended)\n"
            }
            if let floorsDescended = pedometerData?.floorsDescended {
                text += "下楼: \(floorsDescended)\n"
            }
            if let currentPace = pedometerData?.currentPace {
                text += "速度: \(currentPace)m/s\n"
            }
            if let currentCadence = pedometerData?.currentCadence {
                text += "速度: \(currentCadence)步/秒\n"
            }
            
            //在线程中更新文本框数据
            DispatchQueue.main.async{
                if let numberOfSteps = pedometerData?.numberOfSteps {
                    
                    self.stepsLabel.text = "\(Int((numberOfSteps)))"
//                    self.progressView.setProgress(Int(self.stepsLabel.text!)!/100, animated: true)
//                    self.progressView.setProgress(Int(self.stepsLabel.text!)!/100, animated: true)
//                    self.progressView.setProgress(11, animated: true)
                    self.progressView.setProgress(25, animated: true)
                    print("&&&&&&&&&&&&&&&&",numberOfSteps)
                    print("&&&&&&&&&&&&&&&&",self.stepsLabel.text)
                    print("&&&&&&&&&&&&&&&&",Int(self.stepsLabel.text!)!/100)
                }
//                text.ext_debugPrintAndHint()
                
                self.showChart(horizontal: false)
                if let chart = self.chart {
                    self.barView.addSubview(chart.view)
                }
            }
        })
    }

}
