import 'package:flutter/material.dart';
import 'package:reel_calendar/constants/icons_constants.dart';
import 'package:reel_calendar/enums/event_link.dart';

String iconForEventLink(EventLinkType type) {
  switch (type) {
    case EventLinkType.telegram:
      return iconTelegram;
    case EventLinkType.whatsapp:
      return iconWhatsapp;
    case EventLinkType.zoom:
      return iconZoom;
    case EventLinkType.email:
      return iconMail;
    case EventLinkType.phone:
      return iconPhone;
    case EventLinkType.url:
      return iconChrome;
  }
}

Color colorForEventLink(EventLinkType type) {
  switch (type) {
    case EventLinkType.telegram:
      return Colors.blueAccent;
    case EventLinkType.whatsapp:
      return Colors.green;
    case EventLinkType.zoom:
      return Colors.blue;
    case EventLinkType.email:
      return Colors.black;
    case EventLinkType.phone:
      return Colors.black;
    case EventLinkType.url:
      return Colors.orangeAccent;
  }
}
