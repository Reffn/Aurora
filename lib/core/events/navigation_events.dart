import 'package:dis_app/core/events/app_event.dart';

/// Event: Navigation zu neuer Page
class NavigationChangedEvent extends AppEvent {
  NavigationChangedEvent(this.pageIndex);
  final int pageIndex;
}

/// Event: Aktuelle Navigation wurde angefordert (Query)
class NavigationRequestedEvent extends AppEvent {
  NavigationRequestedEvent();
}

/// Event: Antwort auf NavigationRequestedEvent
class NavigationResponseEvent extends AppEvent {
  NavigationResponseEvent(this.currentPageIndex);
  final int currentPageIndex;
}
