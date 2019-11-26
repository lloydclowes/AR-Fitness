//
//  PeakFinder.swift
//  LV8Sport
//
//  Created by Pawel Ambrozej on 29/10/2019.
//  Copyright © 2019 LV8Sport. All rights reserved.
//

import Foundation

final class PeakFinder {
    
    static var relHeight = 0.5
    
    // Peak finder:
    // data - input array of Double values to analyze
    // minimumHeight, maximumHeight - threshold of the peak values to eliminate high peaks
    // distance - minimum distance between two peaks
    // minWidth - minimum width of the peak measured at the relHeight of its prominence (default value is 0.5 so it's measured at half the prominence height)
    // return -> array of touples. First value is the index of the given array where peak was found. Second value is the height of the peak at this point
    
    static func findPeaks(data: [Double], minimumHeight:Double?, maximumHeight: Double?, distance: Int?, minWidth: Int?) -> [(Int,Double)] {

        var result = findLocalMaxima(data: data)
        if minimumHeight != nil || maximumHeight != nil {
            result = peaksByHeight(peaks: result, minimumHeight: minimumHeight, maximumHeight: maximumHeight)
        }

        if let distance = distance {
            result = peaksByDistance(peaks: result, distance: distance)
        }
        
        if let minWidth = minWidth {
            let (prominences,leftBases,rightBases) = peakProminences(data: data, peaks: result, prominencesWindowLength: 0)
            result = peakWidths(data: data, peaks: result, relHeight: relHeight, prominences: prominences, leftBases: leftBases, rightBases: rightBases, minWidth: minWidth)
        }
        return result
    }
    
    private static func findLocalMaxima(data: [Double]) -> [(Int,Double)] {

        var midpoints: [Int] = []
        var leftEdges: [Int] = []
        var rightEdges: [Int] = []
        var m = 0
        var result = Array<(Int,Double)>()
        var index = 1
        let maxIndex = data.endIndex-2
        
        while index < maxIndex {

            if data[index - 1] < data[index] {
                var nextIndex = index + 1

                while nextIndex < maxIndex && data[nextIndex] == data[index]{
                        nextIndex += 1
                }

                if data[nextIndex] < data[index] {
                    leftEdges.append(index)
                    rightEdges.append(nextIndex - 1)
                    midpoints.append(index)
                    m += 1
                    index = nextIndex
                }

            }
            index += 1
        }
        for index in midpoints.indices {
            result.append((midpoints[index],data[midpoints[index]]))
        }
        return result
    }
    
    static private func peaksByHeight(peaks: [(Int,Double)], minimumHeight: Double?, maximumHeight: Double?) -> [(Int,Double)] {
        var result = peaks
        var keepFlags: [Int] = Array(repeating: 1, count: peaks.count)
        for index in peaks.indices {
            if let minimum = minimumHeight {
                if peaks[index].1 < minimum {
                    keepFlags[index] = 0
                }
            }
            if let maximum = maximumHeight {
                if peaks[index].1 > maximum {
                    keepFlags[index] = 0
                }
            }
        }
        
        for index in stride(from: peaks.count-1, to: -1, by: -1)  {
            if keepFlags[index] == 0 {
                result.remove(at: index)
            }
        }
        
        return result
    }
    
    static private func peaksByDistance(peaks: [(Int,Double)], distance: Int) -> [(Int,Double)] {
        var peaks = peaks
        var keepFlags: [Int] = Array(repeating: 1, count: peaks.count)

        for index in stride(from: peaks.count-1, to: -1, by: -1) {
            
            if keepFlags[index] == 0 {
                continue
            }
            
            var previousIndex = index - 1
            
            while 0 <= previousIndex && peaks[index].0 - peaks[previousIndex].0 < distance {
                if peaks[index].1 > peaks[previousIndex].1 {
                    keepFlags[previousIndex] = 0
                }
                previousIndex -= 1
            }
            
            var nextIndex = index + 1
            
            while nextIndex < peaks.count && peaks[nextIndex].0 - peaks[index].0 < distance {
                if peaks[index].1 > peaks[nextIndex].1 {
                    keepFlags[nextIndex] = 0
                }
                nextIndex += 1
            }
        }
        for index in stride(from: peaks.count-1, to: -1, by: -1)  {
            if keepFlags[index] == 0 {
                peaks.remove(at: index)
            }
        }
        return peaks
    }
    
    static private func peakProminences(data: [Double], peaks: [(Int,Double)], prominencesWindowLength: Int) -> ([Double],[Int],[Int]) {

        var prominences = [Double](repeating: 0, count: peaks.count)
        
        var leftBases = [Int](repeating: 0, count: peaks.count),
            rightBases = [Int](repeating: 0, count: peaks.count)
        
        var leftMin = 0.0,
            rightMin = 0.0
        
        var peak = 0,
            iMin = 0,
            iMax = 0,
            index = 0

        var showWarning = false

        for peakNumber in peaks.indices {
            peak = peaks[peakNumber].0
            iMin = 0
            iMax = data.count - 1
            if !(iMin <= peak && peak <= iMax) {
                fatalError("peak {} is not a valid index for `data` \(peak)")
            }
            if 2 <= prominencesWindowLength {
                iMin = max(peak - (prominencesWindowLength / 2), iMin)
                iMax = min(peak + (prominencesWindowLength / 2), iMax)
            }
            
            leftBases[peakNumber] = peak
            index = peak
            leftMin = data[peak]
            while iMin <= index && data[index] <= data[peak]{
                if data[index] < leftMin {
                        leftMin = data[index]
                        leftBases[peakNumber] = index
                }
                index -= 1
            }

            rightBases[peakNumber] = peak
            index = peak
            rightMin = data[peak]
            while index <= iMax && data[index] <= data[peak] {
                if data[index] < rightMin{
                        rightMin = data[index]
                        rightBases[peakNumber] = index
                }
                index += 1
            }
            prominences[peakNumber] = data[peak] - max(leftMin, rightMin)
            if prominences[peakNumber] == 0 {
                    showWarning = true
            }
        }
        if showWarning {
            print("some peaks have a prominence of 0")
        }
        
        return (prominences,leftBases,rightBases)
    }
    
    static private func peakWidths(data: [Double], peaks: [(Int,Double)], relHeight: Double, prominences: [Double], leftBases: [Int], rightBases: [Int], minWidth: Int) -> [(Int,Double)] {

        var peaks = peaks
        var widths = [Double](repeating: 0, count: peaks.count),
            widthHeights = [Double](repeating: 0, count: peaks.count),
            leftIps = [Double](repeating: 0, count: peaks.count),
            rightIps = [Double](repeating: 0, count: peaks.count)
        var height, leftIp, rightIp: Double
        var peak, index, iMax, iMin: Int
        var showWarning = false
        
        var keepFlags = [Int](repeating: 1, count: peaks.count)

        if relHeight < 0 {
            print("relHeight` must be greater or equal to 0.0")
        }
        if !(peaks.count == prominences.count && prominences.count == leftBases.count && leftBases.count == rightBases.count) {
                
            print("arrays in `prominence_data` must have the same shape as `peaks`")
        }

        for peakIndex in peaks.indices {
            iMin = leftBases[peakIndex]
            iMax = rightBases[peakIndex]
            peak = peaks[peakIndex].0
            
            if !(0 <= iMin && iMin <= peak && peak <= iMax && iMax < data.count){
                    print("prominence data is invalid for peak {}")
            }
            
            widthHeights[peakIndex] = data[peak] - prominences[peakIndex] * relHeight
            height = widthHeights[peakIndex]

            index = peak
            
            while iMin < index && height < data[index] {
                index -= 1
            }
            leftIp = Double(index)
            if data[index] < height {
                leftIp += (height - data[index]) / (data[index + 1] - data[index])
            }
            
            index = peak
            while index < iMax && height < data[index]{
                index += 1
            }
            
            rightIp = Double(index)
            
            if  data[index] < height{
                rightIp -= (height - data[index]) / (data[index - 1] - data[index])
            }
            widths[peakIndex] = rightIp - leftIp
            if widths[peakIndex] == 0 {
                showWarning = true
            }
            
            leftIps[peakIndex] = leftIp
            rightIps[peakIndex] = rightIp

        }
        if showWarning{
            print("some peaks have a width of 0")
        }
        
        for index in widths.indices {
            if widths[index] < Double(minWidth) {
                keepFlags[index] = 0
            }
        }
        
        for index in stride(from: peaks.count-1, to: -1, by: -1)  {
            if keepFlags[index] == 0 {
                peaks.remove(at: index)
            }
        }
        
        return peaks
    }

}
