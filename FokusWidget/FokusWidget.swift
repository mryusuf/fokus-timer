//
//  FokusWidget.swift
//  FokusWidget
//
//  Created by Indra Permana on 15/09/22.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct FokusWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

struct LiveFokusTimeActivityView: View {
    let context: ActivityViewContext<FokusTimeAttributes>
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(context.state.activityType.rawValue.localizedCapitalized) Time of:")
                    Text("\(context.state.activityName)").font(.title3).bold()
                }
                Spacer()
                Label {
                    Text(timerInterval: context.state.timer, countsDown: context.state.isCountingDown)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                        .monospacedDigit()
                } icon: {
                    Image(systemName: "timer")
                        .foregroundColor(.accentColor)
                }.font(.title3).bold()
            }
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            
            Spacer()
        }
        .activitySystemActionForegroundColor(context.state.activityType == .focus_time ? Color("focus") : Color("break"))
        .activityBackgroundTint(.secondary)
    }
}

@main
struct FokusWidget: Widget {
    let kind: String = "FokusWidget"

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FokusTimeAttributes.self) { context in
            // Create the view that appears on the Lock Screen and as a
            // banner on the Home Screen of devices that don't support the
            // Dynamic Island.
            // ...
            LiveFokusTimeActivityView(context: context)
        } dynamicIsland: { context in
            // Create the views that appear in the Dynamic Island.
            // ...
            DynamicIsland {
                // Expanded View
                DynamicIslandExpandedRegion(.leading) {
                    Text("\(context.state.activityType.rawValue.localizedCapitalized) Time")
                        .foregroundColor(context.state.activityType == .focus_time ? Color("focus") : Color("break"))
                        .font(.title3)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Label {
                        Text(timerInterval: context.state.timer, countsDown: context.state.isCountingDown)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 70)
                            .monospacedDigit()
                    } icon: {
                        Image(systemName: "timer")
                            .foregroundColor(.accentColor)
                    }.font(.title3)
                }
            } compactLeading: {
                Label("\(context.state.activityType.rawValue.localizedCapitalized) Time", systemImage: "timer")
                    .foregroundColor(context.state.activityType == .focus_time ? Color("focus") : Color("break"))
                    .font(.caption2)
            } compactTrailing: {
                Text(timerInterval: context.state.timer, countsDown: context.state.isCountingDown)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 40)
                    .monospacedDigit()
                    .font(.caption2)
            } minimal: {
                VStack(alignment: .center) {
                    Image(systemName: "timer")
                        .foregroundColor(context.state.activityType == .focus_time ? Color("focus") : Color("break"))
                    Text(timerInterval: context.state.timer, countsDown: context.state.isCountingDown)
                        .multilineTextAlignment(.trailing)
                        .monospacedDigit()
                        .font(.caption2)
                }
            }
            .keylineTint(.cyan)
        }
    }
}

//struct FokusWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        FokusWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
