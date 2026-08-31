import WidgetKit
import SwiftUI

/// Registers all Lovelynk home / lock screen widgets.
/// Add new widgets here as each tier is implemented.
@main
struct LovelynkWidgetBundle: WidgetBundle {
    var body: some Widget {
        DaysTogetherWidget()
        InitialsWidget()
        PartnerDistanceWidget()
        AnniversaryWidget()
    }
}
