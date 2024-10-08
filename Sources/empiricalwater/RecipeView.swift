//
//  RecipeView.swift
//  empirical water
//
//  Created by Erik Gomez on 08/23/24.
//

import Foundation
import SwiftUI

struct RecipeView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("forceDarkMode") var forceDarkMode: Bool = false
    @AppStorage("minimalButtons") var minimalButtons: Bool = false
    @AppStorage("showExtractionBooster") var showExtractionBooster: Bool = false
    @AppStorage("useVolumetricMeasurementHardness") var useVolumetricMeasurementHardness: Bool = false
    @AppStorage("useVolumetricMeasurementBuffer") var useVolumetricMeasurementBuffer: Bool = false
    @AppStorage("useVolumetricMeasurementExtractionBooster") var useVolumetricMeasurementExtractionBooster: Bool = false
    @AppStorage("useVolumetricMeasurementZeroTDSWater") var useVolumetricMeasurementZeroTDSWater: Bool = false
    @AppStorage("lastVersionLaunched") var lastVersionLaunched: String = "0.0"
    @State var options = [
        Option(title: "hardness"),
        Option(title: "buffer"),
        Option(title: "extraction booster"),
        Option(title: "zero TDS water"),
        Option(title: "Force Dark Mode"),
        Option(title: "Minimal Buttons"),
        Option(title: "Show extraction booster")
    ]
    @State var isToggled: Bool = false
    @State private var isPresented: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 10) {
                        ZStack {
                            Image("Icon_Blank")
                                .resizable()
                                .frame(width: 125, height: 125)

                            Menu(content: {
                                Picker("Water", selection: $appState.water) {
                                    ForEach(Waters.allCases) { water in
                                        Text(water.selectedWater.name)
                                            .tag(water)
                                    }
                                }
                            }, label: {
                                VStack {
                                    HStack(spacing: 5) {
                                        Text("\(appState.water.selectedWater.name)")
                                            .foregroundColor(.white)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        if !minimalButtons {
                                            Text("\(Image(systemName: "chevron.up.chevron.down"))")
                                                .foregroundColor(.white)
                                        }
                                    }
                                        .lineLimit(1)
                                        .frame(width: 80)
                                        #if !SKIP
                                        .minimumScaleFactor(0.001)
                                        #endif
                                }
                                .frame(width: 125, height: 125)
                                #if !SKIP
                                    .contentShape(Circle())
                                #endif
                            })
                            .offset(y: 10)
                        }
                        
                        VStack {
                            if !appState.water.selectedWater.note.isEmpty {
                                Text(LocalizedStringKey(appState.water.selectedWater.note))
                                    .font(.callout)
                                    .padding(.vertical)
                            }
                            if !mainAppState.water.selectedWater.description.isEmpty {
                                HStack {
                                    Text(LocalizedStringKey(mainAppState.water.selectedWater.description))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        HStack {
                            Menu(content: {
                                Picker("", selection: $appState.brewType) {
                                    ForEach(BrewTypes.allCases) { brewtype in
                                        Text(brewtype.selectedBrewType.name)
                                            .tag(brewtype)
                                    }
                                }
                            }, label: {
                                HStack(spacing: 5) {
                                    Text("\(appState.brewType.selectedBrewType.name)")
                                    if !minimalButtons {
                                        Text("\(Image(systemName: "chevron.up.chevron.down"))")
                                    }
                                }
                                .frame(width: minimalButtons ? 110.0 : 140.0) // Ensures the text is centered within the button
                                .padding()
  
                            })
                            .foregroundColor(.white)
                            .background(appState.brewType.brewColor)
                            .cornerRadius(8)

                            Menu(content: {
                                Picker("Unit", selection: $appState.unit) {
                                    ForEach(Units.allCases) { unit in
                                        Text(unit.selectedUnit.name)
                                            .tag(unit)
                                    }
                                }
                            }, label: {
                                HStack(spacing: 5) {
                                    Text("\(appState.unit.selectedUnit.name)")
                                    if !minimalButtons {
                                        Text("\(Image(systemName: "chevron.up.chevron.down"))")
                                    }
                                }
                                    .frame(minWidth: 110) // Ensures the text is centered within the button
                                    .padding()
                            })
                            .foregroundColor(.white)
                            .background(appState.unit.unitColor)
                            .cornerRadius(8)
                        }
                        
                        HStack {
                            Text(appState.unit == .milliliter ? "mL" : "\(appState.unit.selectedUnit.name)s")
                                .foregroundColor(.secondary)
                            Slider(
                                value: $appState.unitVolume,
                                in: appState.unit == .milliliter ? 100.0...1000.0 : appState.unit == .liter ? 1.0...10.0 : 0.0...10.0,
                                step: appState.unit == .milliliter ? 5.0 : appState.unit == .liter ? 0.25 : 1.0
                            )
                            .tint(Color(red: 21.0 / 255.0, green: 67.0 / 255.0, blue: 109.0 / 255.0))
                            Text(appState.unit == .liter ? String(format: "%.2f", appState.unitVolume) : String(Int(appState.unitVolume)))
                                .frame(minWidth: 35)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    if !appState.water.selectedWater.note.isEmpty {
                        Text(LocalizedStringKey(appState.water.selectedWater.note))
                            .font(.callout)
                    }
                    
                    VStack(spacing: 10) {
                        ForEach(["hardness", "buffer", "extraction booster"], id: \.self) { component in
                            let volumetricValue = {
                                switch component {
                                case "hardness": return useVolumetricMeasurementHardness
                                case "buffer": return useVolumetricMeasurementBuffer
                                case "extraction booster": return useVolumetricMeasurementExtractionBooster
                                default: return false
                                }
                            }()
                            let value = calculateBrewTypeValues(for: component, volumetric: volumetricValue)
                            if component == "extraction booster" && !showExtractionBooster {
                                EmptyView()
                            } else {
                                HStack {
                                    if component == "extraction booster" {
                                        SuperscriptText(regularText: "\(component)", superscriptText: "Optional", font: Font.callout)
                                    } else {
                                        Text("\(component)")
                                    }
                                    Spacer()
                                    Text("\(value) \(volumetricValue ? "mL" : "grams")")
                                        .bold()
                                }
                                .font(.callout)
                                .foregroundColor(.white)
                            }
                        }
                    }
                    .listRowBackground(Color(red: 21.0 / 255.0, green: 67.0 / 255.0, blue: 109.0 / 255.0))
                    
                    HStack {
                        Text("zero TDS water")
                            .font(.callout)
                        Spacer()
                        let zeroTDSWater = calculateZeroTDSWater()
                        Text("\(zeroTDSWater) \(useVolumetricMeasurementZeroTDSWater ? "mL" : "grams")")
                            .font(.callout)
                            .bold()
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color.gray)
                    
                    #if !SKIP
                    DisclosureGroup("Optional Features", isExpanded: $appState.isOptionsExpanded) {
                        VStack(spacing: 10) {
                            Text("Volumetric - Convert from grams (g) to milliliters (mL)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            OptionRow(value: $useVolumetricMeasurementHardness, option: options[0])
                            OptionRow(value: $useVolumetricMeasurementBuffer, option: options[1])
                            OptionRow(value: $useVolumetricMeasurementExtractionBooster, option: options[2])
                            OptionRow(value: $useVolumetricMeasurementZeroTDSWater, option: options[3])
                            Text("Additional Features")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            OptionRow(value: $forceDarkMode, option: options[4])
                            OptionRow(value: $minimalButtons, option: options[5])
                            OptionRow(value: $showExtractionBooster, option: options[6])
                        }
                        .foregroundColor(.primary)
                    }
                    .foregroundColor(.secondary)
                    .accentColor(appState.isOptionsExpanded ? Color(red: 21.0 / 255.0, green: 67.0 / 255.0, blue: 109.0 / 255.0) : .secondary)
                    .onAppear {
                        if appVersion.compare(lastVersionLaunched, options: .numeric) == .orderedDescending {
                            appState.isOptionsExpanded = true
                            lastVersionLaunched = appVersion
                        }
                    }
                    #endif
                    VStack {
                        HStack {
                            Text(LocalizedStringKey(mainAppState.brewType.selectedBrewType.note))
                                .foregroundColor(.secondary)
                                .font(.caption2)
                        }
                        Divider()
                            .padding(.vertical, 10)
                        HStack(spacing: 0) {
                            Text("Purchase these concentrates at ")
                                .foregroundColor(.secondary)
                            
                            Link("empirical", destination: URL(string: "https://empiricalwater.com")!)
                                .bold()
                                .foregroundColor(Color(red: 21.0/255.0, green: 67.0/255.0, blue: 109.0/255.0))
                            
                            Text(" ")
                                .foregroundColor(.secondary)
                            
                            Link("water", destination: URL(string: "https://empiricalwater.com")!)
                                .bold()
                                .foregroundColor(Color(red: 0.0/255.0, green: 199.0/255.0, blue: 255.0/255.0))
                        }
                        .font(.caption)
                    }
                }
                .listRowSeparator(.hidden)

                Section {
                    Text("Thanks to [Erik Gomez](https://github.com/erikng), the author of [Blossom Rain](https://github.com/erikng/Blossom-Rain), which this code is based on for our application.")
                        .foregroundColor(.secondary)
                        .font(.caption2)
                }
            }
            #if !SKIP
            .listSectionSpacing(12)
            #endif
        }
        .onChange(of: appState.unit) {
            if appState.unit == .milliliter {
                appState.unitVolume = 100.0
            } else {
                appState.unitVolume = 1.0
            }
        }
    }
}

struct OptionRow: View {
    @Binding var value: Bool
    let option: Option

    var body: some View {
        Toggle(isOn: $value) {
            Text(option.title)
        }
        .tint(Color(red: 21.0 / 255.0, green: 67.0 / 255.0, blue: 109.0 / 255.0))
    }
}

#if !SKIP
struct SuperscriptText: View {
    let regularText: String
    let superscriptText: String
    var font: Font
    
    @Environment(\.sizeCategory) var sizeCategory
    
    // Define a mapping between SwiftUI Font and UIFont
    private func uiFont(for font: Font) -> UIFont {
        switch font {
        case .title:
            return UIFont.preferredFont(forTextStyle: .title1)
        case .headline:
            return UIFont.preferredFont(forTextStyle: .headline)
        case .body:
            return UIFont.preferredFont(forTextStyle: .body)
        case .callout:
            return UIFont.preferredFont(forTextStyle: .callout)
        case .footnote:
            return UIFont.preferredFont(forTextStyle: .footnote)
        case .caption:
            return UIFont.preferredFont(forTextStyle: .caption1)
        default:
            return UIFont.preferredFont(forTextStyle: .body) // Default UIFont
        }
    }
    
    func dynamicFontSize(baseSize: CGFloat) -> CGFloat {
        uiFont(for: font).withSize(baseSize).pointSize
    }
    
    func dynamicBaselineOffset(for fontSize: CGFloat) -> CGFloat {
        return 6.0 * (fontSize / uiFont(for: font).pointSize)
    }
    
    var body: some View {
        let baseFontSize = uiFont(for: font).pointSize
        let superscriptFontSize = dynamicFontSize(baseSize: baseFontSize * 0.5) // Half the size of desired font
        let baselineOffset = dynamicBaselineOffset(for: superscriptFontSize)
        HStack(alignment: .top, spacing: 3) {
            Text(regularText)
                .font(font)
            
            Text(superscriptText)
                .font(.system(size: superscriptFontSize))
                .baselineOffset(baselineOffset)
        }
    }
}
#else
struct SuperscriptText: View {
    let regularText: String
    let superscriptText: String
    var font: Font

    var body: some View {
        HStack {
            Text(regularText)
                .font(.callout)
            Text(superscriptText)
                .font(.caption2)
                
        }
    }
}
#endif
