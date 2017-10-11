//
//  LineChartStaticsViewController.swift
//  Survival
//
//  Created by YANGWEI on 27/09/2017.
//  Copyright © 2017 GINOF. All rights reserved.
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
        self.view = ChartView
        
        ChartView.data = self.setUpStaticsData(SurvivalStatic);
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
        leftAxis.axisMaximum = 400.0
        leftAxis.axisMinimum = 0.0
        leftAxis.gridLineDashLengths = [5.0, 5.0]
        leftAxis.drawZeroLineEnabled = false;
        leftAxis.drawLimitLinesBehindDataEnabled = true;
        
        ChartView.rightAxis.enabled = false;
        ChartView.legend.form = .line
        
    }
    
    func setUpStaticsData(_ statistics:[SurvivalStatistic]) -> LineChartData?{

        var openBadValues:[ChartDataEntry] = []
        var conservativeBadValues:[ChartDataEntry] = []
        var strategyBadValues:[ChartDataEntry] = []
        var niceValues:[ChartDataEntry] = []
        var conservativeValues:[ChartDataEntry] = []
        var meanValues:[ChartDataEntry] = []
        var openMeanValues:[ChartDataEntry] = []

        for index in 0...statistics.count-1 {
            
            openBadValues.append(ChartDataEntry(x: Double(index), y: Double(statistics[index].OpenBad)))
            conservativeBadValues.append(ChartDataEntry(x: Double(index), y: Double(statistics[index].ConservativeBad)))
            strategyBadValues.append(ChartDataEntry(x: Double(index), y: Double(statistics[index].StrategyBad)))
            niceValues.append(ChartDataEntry(x: Double(index), y: Double(statistics[index].Nice)))
            conservativeValues.append(ChartDataEntry(x: Double(index), y: Double(statistics[index].Conservative)))
            meanValues.append(ChartDataEntry(x: Double(index), y: Double(statistics[index].Mean)))
            openMeanValues.append(ChartDataEntry(x: Double(index), y: Double(statistics[index].OpenMean)))
        }
        
        let OpenBadDataSet = self.setupDataSet("Open Bad", values: openBadValues, color: .red)
        let ConservativeBadDataSet = self.setupDataSet("Conservative Bad", values: conservativeBadValues, color: .brown)
        let StrategyBadDataSet = self.setupDataSet("Strategy Bad", values: strategyBadValues, color: .yellow)
        let NiceDataSet = self.setupDataSet("Nice", values: niceValues, color: .green)
        let ConservativeDataSet = self.setupDataSet("Conservative", values: conservativeValues, color: .orange)
        let MeanDataSet = self.setupDataSet("Mean", values: meanValues, color: .cyan)
        let OpenMeanDataSet = self.setupDataSet("OpenMean", values: openMeanValues, color: .darkGray)
        let staticDataSets = LineChartData(dataSets: [OpenBadDataSet,ConservativeBadDataSet,StrategyBadDataSet,NiceDataSet,ConservativeDataSet,MeanDataSet,OpenMeanDataSet])
        
        return staticDataSets
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



