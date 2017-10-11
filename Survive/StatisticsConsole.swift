//
//  StatisticsConsole.swift
//  Survive
//
//  Created by YANGWEI on 19/09/2017.
//  Copyright © 2017 GINOF. All rights reserved.
//

import Foundation
import Charts

class StatisticsChart: LineChartView, ChartViewDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.chartDescription?.enabled = false
        self.dragEnabled = true
        self.setScaleEnabled(true)
        self.pinchZoomEnabled = true
        self.drawGridBackgroundEnabled = true
        
        self.leftAxis.removeAllLimitLines()
        self.leftAxis.axisMaximum = 200.0;
        self.leftAxis.axisMinimum = -50.0;
        self.leftAxis.gridLineDashLengths = [CGFloat(5.0), CGFloat(5.0)]
        self.leftAxis.drawZeroLineEnabled = false;
        self.leftAxis.drawLimitLinesBehindDataEnabled = true;

        self.rightAxis.enabled = false
        
        self.legend.form = .line
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
