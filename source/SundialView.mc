using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time.Gregorian as Calendar;
// using Toybox.Lang.Number as Num;

class SundialView extends Ui.WatchFace {
  var screenShape;
  var sunNoonTime;
  var sunRiseTime;
  var sunSetTime;
  var twilightStart;
  var twilightEnd;
  var hourNumbers;
  var isAwake;
  var nightTime;

  function initialize() {
    WatchFace.initialize();
    screenShape = Sys.getDeviceSettings().screenShape;
    computeSunEphemeris();
    hourNumbers = [ 3, 6, 9, 12, 15, 18, 21, 24 ];
  }

  // Load your resources here
  function onLayout(dc) {
    // do nothing ?
    // setLayout(Rez.Layouts.WatchFace(dc));
  }

  function computeSunEphemeris() {
    // For now the value are just handcoded to start testing...
    // Vail, December 28
    sunNoonTime = new DayTime(12, 04, 0);
    sunRiseTime = new DayTime(7, 23, 0);
    sunSetTime = new DayTime(16, 45, 0);
    twilightStart = new DayTime(6, 53, 0);
    twilightEnd = new DayTime(17, 16, 0);

    // short day:
    // sunNoonTime = new DayTime(11, 54, 0);
    // sunRiseTime = new DayTime(6, 55, 0);
    // sunSetTime = new DayTime(16, 54, 0);

    // long day:
    // sunNoonTime = new DayTime(13, 16, 0);
    // sunRiseTime = new DayTime(5, 48, 0);
    // sunSetTime = new DayTime(20, 32, 0);
  }

  // Return the radius from the center of the screen to the edge.
  // It takes into account if the face is round or semi-round.
  function radiusFromAngle(dc, angle) {
    // default radius for cases not handled yet...
    var radius = 0.5 * dc.getWidth().toFloat() / Math.sqrt(2);
    if (Sys.SCREEN_SHAPE_ROUND == screenShape) {
      radius = dc.getWidth() / 2.0;
    } else if (Sys.SCREEN_SHAPE_SEMI_ROUND == screenShape) {
      var screenRatio = dc.getHeight().toFloat() / dc.getWidth().toFloat();

      if (angle > Math.PI) {
        angle = angle - 2.0 * Math.PI;
      }
      var cutoffAngle = Math.asin(screenRatio);
      if ((angle > cutoffAngle and angle < Math.PI - cutoffAngle) or
          (angle < -cutoffAngle and angle > -Math.PI + cutoffAngle)) {
        radius = (0.5 * dc.getHeight().toFloat() / Math.sin(angle)).abs();
      } else {
        radius = dc.getWidth().toFloat() / 2.0;
      }
    }
    return radius;
  }

  function drawMark(dc, time, margin, thickness) {
    var width = dc.getWidth();
    var height = dc.getHeight();

    var center_x = width / 2;
    var center_y = height / 2;
    var a = time.toRad(sunNoonTime);
    // get radius for our shape...
    var radius = radiusFromAngle(dc, a);
    var cosa = Math.cos(a);
    var sina = Math.sin(a);
    var sx = center_x + (radius - margin) * cosa;
    var sy = center_y - (radius - margin) * sina;
    // 12 = hard coded (for now) distance from center
    var ex = center_x + 12.0 * cosa;
    var ey = center_y - 12.0 * sina;
    dc.setPenWidth(thickness);
    dc.drawLine(sx, sy, ex, ey);

    if (time.minutes == 0) {
      for (var i = 0; i < hourNumbers.size(); i++) {
        if (time.hour != hourNumbers[i]) {
          continue;
        }
        radius = radius - 12;
        var tx = center_x + radius * cosa;
        var ty = center_y - radius * sina;
        dc.drawText(tx, ty, Gfx.FONT_MEDIUM, time.hour,
                    Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
      }
    }
  }

  function drawShadow(dc, time) {
    var width = dc.getWidth();
    var height = dc.getHeight();
    var center_x = width / 2;
    var center_y = height / 2;

    var current_a = time.toRad(sunNoonTime);
    // -18 define the length of the shadow: should be depending of the sun
    // height...
    var radius = radiusFromAngle(dc, current_a) - 18.0;
    var noon_a = time.toRad(sunNoonTime);
    var cosa = Math.cos(current_a);
    var sina = Math.sin(current_a);
    var hor_line = [ [ -1, 3 ], [ radius, 2 ], [ radius, -2 ], [ -1, -3 ] ];
    var shadow = new[4];
    for (var i = 0; i < 4; i++) {
      var x = (hor_line[i][0] * cosa) - (hor_line[i][1] * sina);
      var y = (hor_line[i][0] * sina) + (hor_line[i][1] * cosa);
      shadow[i] = [ center_x + x, center_y - y ];
    }
    if (nightTime) {
      // dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    } else {
      // dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
      dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
    }
    dc.fillPolygon(shadow);
    /*
    var med_length =
        (center_x < center_y) ? center_x * 2 / 3 : center_y * 2 / 3;
    var style = [
      [ center_x, center_y ],
      [ center_x, (nightTime) ? height * 2 / 3 : height / 3 ],
      [ center_x + med_length * cosa, center_y - med_length * sina ]
    ];
    dc.fillPolygon(style);
    */
  }

  function drawHourLines(dc) {
    // noonAngle = timeToRad(sunNoonTime);
    // Sys.println("SunRise : " + sunRiseTime.hour + ":" +
    // sunRiseTime.minutes);
    // Sys.println("SunSet : " + sunSetTime.hour + ":" + sunSetTime.minutes);
    var margin = 24;
    var t = new DayTime(sunRiseTime, 0, 0);
    if (nightTime) {
      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
      for (var h = sunSetTime.hour + 1; h <= sunRiseTime.hour + 24; h++) {
        if (h > 24) {
          t.hour = h - 24;
        } else {
          t.hour = h;
        }
        drawMark(dc, t, margin, 1);
      }
    } else {
      dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
      for (var h = sunRiseTime.hour + 1; h <= sunSetTime.hour; h++) {
        t.hour = h;
        drawMark(dc, t, margin, 1);
      }
    }
  }

  function drawDayZone(dc) {
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    var width = dc.getWidth();
    var height = dc.getHeight();
    var center_x = width / 2;
    var center_y = height / 2;
    var a_start = sunRiseTime.toRad(sunNoonTime);
    var a_end = sunSetTime.toRad(sunNoonTime);
    var r_start = radiusFromAngle(dc, a_start);
    var r_end = radiusFromAngle(dc, a_end);
    var x_start = center_x + r_start * Math.cos(a_start);
    var y_start = center_y - r_start * Math.sin(a_start);
    var x_end = center_x + r_end * Math.cos(a_end);
    var y_end = center_y - r_end * Math.sin(a_end);
    var points = [
      [ center_x, center_y ], [ x_start, y_start ], [ 0, y_start ], [ 0, 0 ],
      [ width, 0 ], [ width, y_end ], [ x_end, y_end ],
      [ center_x, center_y ]
    ];
    dc.fillPolygon(points);

    // Print the sunrise and sunset times
    var pos_s_x;
    var pos_s_y;
    var pos_e_x;
    var pos_e_y;
    if (nightTime) {
      dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
      if (a_start > Math.PI) {
        pos_s_x = center_x + (r_start - 4) * Math.cos(a_start);
        pos_s_y = center_y - (r_start * 2 / 3) * Math.sin(a_start) - 19;
        pos_e_x = center_x + (r_end - 4) * Math.cos(a_end);
        pos_e_y = center_y - (r_end * 2 / 3) * Math.sin(a_end) - 19;
      } else {
        pos_s_x = center_x + (r_start - 4) * Math.cos(a_start);
        pos_s_y = center_y - (r_start - 4) * Math.sin(a_start) - 19;
        pos_e_x = center_x + (r_end - 4) * Math.cos(a_end);
        pos_e_y = center_y - (r_end - 4) * Math.sin(a_end) - 19;
      }
    } else {
      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
      if (a_start > Math.PI) {
        pos_s_x = center_x + (r_start - 4) * Math.cos(a_start);
        pos_s_y = center_y - (r_start - 4) * Math.sin(a_start) + 2;
        pos_e_x = center_x + (r_start - 4) * Math.cos(a_start);
        pos_e_y = center_y - (r_start - 4) * Math.sin(a_start) + 2;
      } else {
        pos_s_x = center_x + (r_start - 4) * Math.cos(a_start);
        pos_s_y = center_y - (r_start * 2 / 3) * Math.sin(a_start) + 2;
        pos_e_x = center_x + (r_end - 4) * Math.cos(a_end);
        pos_e_y = center_y - (r_end * 2 / 3) * Math.sin(a_end) + 2;
      }
    }
    var sunRiseStr = Lang.format(
        "$1$:$2$", [ sunRiseTime.hour, sunRiseTime.minutes.format("%02d") ]);
    dc.drawText(pos_s_x, pos_s_y, Gfx.FONT_SMALL, sunRiseStr,
                Gfx.TEXT_JUSTIFY_LEFT);
    var sunSetStr = Lang.format(
        "$1$:$2$", [ sunSetTime.hour, sunSetTime.minutes.format("%02d") ]);
    dc.drawText(pos_e_x, pos_e_y, Gfx.FONT_SMALL, sunSetStr,
                Gfx.TEXT_JUSTIFY_RIGHT);
  }

  function updateFace(dc, clock) {
    if (clock.greaterThan(sunSetTime) or clock.lowerThan(sunRiseTime)) {
      nightTime = true;
    } else {
      nightTime = false;
    }
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    dc.clear();
    drawDayZone(dc);
    drawHourLines(dc);
    drawShadow(dc, clock);

    var timeStr =
        Lang.format("$1$:$2$", [ clock.hour, clock.minutes.format("%02d") ]);
    var pos_x = dc.getWidth() / 2;
    var pos_y = nightTime ? dc.getHeight() / 4 : dc.getHeight() * 3 / 4;
    if (nightTime) {
      dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
    } else {
      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    }
    dc.drawText(pos_x, pos_y, Gfx.FONT_NUMBER_HOT, timeStr,
                Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);

    var now = Time.now();
    var info = Calendar.info(now, Time.FORMAT_LONG);
    var dateStr =
        Lang.format("$1$ $2$ $3$", [ info.day_of_week, info.month, info.day ]);
    // 4 = offset from border / 19 = font size for TINY on FR230
    pos_y = nightTime ? 4 : dc.getHeight() - 4 - 19;
    dc.drawText(pos_x, pos_y, Gfx.FONT_SMALL, dateStr, Gfx.TEXT_JUSTIFY_CENTER);
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() {}

  // Update the view
  function onUpdate(dc) {
    // Get and show the current time
    var clockTime = Sys.getClockTime();
    var currentTime = new DayTime(clockTime.hour, clockTime.min, 0);

    // Call the parent onUpdate function to redraw the layout
    // View.onUpdate(dc);

    updateFace(dc, currentTime);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() {}

  // The user has just looked at their watch. Timers and animations may be
  // started here.
  function onExitSleep() { isAwake = true; }

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() {
    isAwake = false;
    Ui.requestUpdate();
  }
}
