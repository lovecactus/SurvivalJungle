//
//  LineChartStaticsViewController.swift
//  Survival
//
//  Created by YANGWEI on 27/09/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import UIKit
import Charts

class LineChartStaticsViewController: UIViewController, ChartViewDelegate {
    let ChartView = LineChartView()
    let SurvivalStatic:[SurvivalStatistic]
    
    init(Statistic: [SurvivalStatistic]) {
        SurvivalStatic = Statistic
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        SurvivalStatic = []
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initialCharts()
        
        ChartView.animate(xAxisDuration: 2.5)
        
        ChartView.data = self.setUpStaticsData(SurvivalStatic);
    }
    
    override func viewWillLayoutSubviews() {
        if #available(iOS 11.0, *) {
            ChartView.frame.origin.x = ChartView.safeAreaInsets.left
            ChartView.frame.origin.y = ChartView.safeAreaInsets.top
            ChartView.frame.size.width = ChartView.bounds.width - ChartView.safeAreaInsets.left - ChartView.safeAreaInsets.right
            ChartView.frame.size.height = ChartView.bounds.height - ChartView.safeAreaInsets.top - ChartView.safeAreaInsets.bottom
        } else {
            // Fallback on earlier versions
        }
        self.view = ChartView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initialCharts() {
        title = "Ceature Survival Statics"
        ChartView.delegate = self
        ChartView.chartDescription?.enabled = false
        ChartView.dragEnabled = false
        ChartView.setScaleEnabled(true)
        ChartView.pinchZoomEnabled = true
        ChartView.drawGridBackgroundEnabled = false
        ChartView.backgroundColor = .white
        
        let leftAxis = ChartView.leftAxis
        leftAxis.axisMaximum = 800.0
        leftAxis.axisMinimum = 0.0
        leftAxis.gridLineDashLengths = [5.0, 5.0]
        leftAxis.drawZeroLineEnabled = false;
        leftAxis.drawLimitLinesBehindDataEnabled = true;
        
        ChartView.rightAxis.enabled = false;
        ChartView.legend.form = .line
        
    }
    
    func setUpStaticsData(_ statistics:[SurvivalStatistic]) -> LineChartData?{

        var staticValues:[String:[ChartDataEntry]] = [:]
        guard let sampleStatistic = statistics.first else {
            return nil
        }
        
        for (key, _) in sampleStatistic {
            let staticValue:[ChartDataEntry] = []
            staticValues[key] = staticValue
        }

        for index in 0...statistics.count-1 {
            let statistic = statistics[index]
            for (_, value) in statistic.enumerated() {
                staticValues[value.key]?.append(ChartDataEntry(x: Double(index), y: value.value))
            }
            
        }

        var staticDataSets:[LineChartDataSet] = []
        for (index, staticValue) in staticValues.enumerated() {
            let color:UIColor
            switch index {
            case 0:
                color = .red
                break
            case 1:
                color = .blue
                break
            case 2:
                color = .cyan
                break
            case 3:
                color = .green
                break
            case 4:
                color = .brown
                break
            case 5:
                color = .orange
                break
            case 6:
                color = .purple
                break
            case 7:
                color = .darkGray
                break
            case 8:
                color = .gray
                break
            case 9:
                color = .magenta
                break
            default:
                color = .black
            }
            staticDataSets.append(self.setupDataSet(staticValue.key, values: staticValue.value, color: color))
        }
        
        return LineChartData(dataSets: staticDataSets)
    }
    
    func setupDataSet(_ name:String, values:[ChartDataEntry], color:UIColor) -> LineChartDataSet{
        let staticDataSet = LineChartDataSet(values: values, label: name)
        staticDataSet.drawIconsEnabled = false
        staticDataSet.drawCirclesEnabled = false
        staticDataSet.drawCircleHoleEnabled = false
        staticDataSet.lineDashLengths = [5.0, 2.5]
        staticDataSet.highlightLineDashLengths = [5.0, 2.5]
        staticDataSet.setColor(color)
        staticDataSet.setCircleColor(color)
        staticDataSet.lineWidth = 1.0
        staticDataSet.circleRadius = 3.0
        staticDataSet.valueFont = .systemFont(ofSize: 9.0)
        staticDataSet.formLineDashLengths = [5.0, 2.5]
        staticDataSet.formLineWidth = 2.0
        staticDataSet.formSize = 15.0
        staticDataSet.fillAlpha = 0.5
        staticDataSet.fill = Fill.fillWithCGColor(color.cgColor)
        staticDataSet.drawFilledEnabled = false
        return staticDataSet
    }
}



