using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
// using Toybox.Lang.Number as Num;

class SundialView extends Ui.WatchFace {
  var screenShape;
  var sunNoonTime;
  var sunRiseTime;
  var sunSetTime;
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
    // short day:
    sunNoonTime = new DayTime(12, 54, 0);
    sunRiseTime = new DayTime(7, 17, 0);
    sunSetTime = new DayTime(18, 30, 0);

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
    dc.setPenWidth(thickness);
    dc.drawLine(sx, sy, center_x, center_y);

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
    var radius = radiusFromAngle(dc, current_a) - 12.0;
    var noon_a = time.toRad(sunNoonTime);
    var cosa = Math.cos(current_a);
    var sina = Math.sin(current_a);
    var hor_line = [ [ 0, 2 ], [ radius, 2 ], [ radius, -2 ], [ 0, -2 ] ];
    var shadow = new[4];
    for (var i = 0; i < 4; i++) {
      var x = (hor_line[i][0] * cosa) - (hor_line[i][1] * sina);
      var y = (hor_line[i][0] * sina) + (hor_line[i][1] * cosa);
      shadow[i] = [ center_x + x, center_y - y ];
    }
    if (nightTime) {
      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    } else {
      dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
    }
    dc.fillPolygon(shadow);
  }

  function drawHourLines(dc) {
    // noonAngle = timeToRad(sunNoonTime);
    // Sys.println(width);
    // Sys.println(height);
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
  }

  ( : test) function runClock() {}

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() {}

  // Update the view
  function onUpdate(dc) {
    // Get and show the current time
    var clockTime = Sys.getClockTime();
    var currentTime = new DayTime(clockTime.hour, clockTime.min, 0);

    var timeString = Lang.format(
        "$1$:$2$", [ clockTime.hour, clockTime.min.format("%02d") ]);
    // var view = View.findDrawableById("TimeLabel");
    // view.setText(timeString);

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
