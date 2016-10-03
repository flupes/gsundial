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

  function initialize() {
    WatchFace.initialize();
    screenShape = Sys.getDeviceSettings().screenShape;
    computeSunEphemeris();
  }

  // Load your resources here
  function onLayout(dc) {
    // do nothing ?
    // setLayout(Rez.Layouts.WatchFace(dc));
  }

  function computeSunEphemeris() {
    sunNoonTime = new DayTime(13, 16, 0);
    sunRiseTime = new DayTime(5, 48, 0);
    sunSetTime = new DayTime(20, 32, 0);
  }

  function radiusFromAngle(a, width, height) {
    var screenRatio = height.toFloat() / width.toFloat();
    var radius;
    if (a > Math.PI) {
      a = a - 2.0 * Math.PI;
    }
    var cutoffAngle = Math.asin(screenRatio);
    if ((a > cutoffAngle and a < Math.PI - cutoffAngle) or
        (a < -cutoffAngle and a > -Math.PI + cutoffAngle)) {
      radius = (0.5 * height.toFloat() / Math.sin(a)).abs();
    } else {
      radius = width.toFloat() / 2.0;
    }
    return radius;
  }

  function drawMark(dc, time, length, thickness) {
    var width = dc.getWidth();
    var height = dc.getHeight();

    var centerX = width / 2;
    var centerY = height / 2;
    var a = time.toRad(sunNoonTime);
    // default radius for unknown shape...
    var radius = 0.5 * width.toFloat() / Math.sqrt(2);
    if (Sys.SCREEN_SHAPE_ROUND == screenShape) {
      radius = width / 2.0;
    } else if (Sys.SCREEN_SHAPE_SEMI_ROUND == screenShape) {
      radius = radiusFromAngle(a, width, height);
    }
    var sx = centerX + radius * Math.cos(a);
    var sy = centerY - radius * Math.sin(a);
    var ex = centerX + (radius - length) * Math.cos(a);
    var ey = centerY - (radius - length) * Math.sin(a);
    Sys.println(time.hour + ":" + time.minute + " --> a=" + Math.toDegrees(a) +
                " radius=" + radius + " sx=" + sx + " sy=" + sy + " ex=" + ey +
                " ey=" + ey);
    dc.setPenWidth(thickness);
    dc.drawLine(sx, sy, ex, ey);
  }

  function drawHours(dc) {
    // noonAngle = timeToRad(sunNoonTime);
    var width = dc.getWidth();
    var height = dc.getHeight();
    // Sys.println(width);
    // Sys.println(height);
    // Sys.println("SunRise : " + sunRiseTime.hour + ":" + sunRiseTime.minute);
    // Sys.println("SunSet : " + sunSetTime.hour + ":" + sunSetTime.minute);
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    var length = 12;
    drawMark(dc, sunRiseTime, length, 1);
    drawMark(dc, sunSetTime, length, 1);
    var t = new DayTime(sunRiseTime, 0, 0);
    for (var h = sunRiseTime.hour + 1; h <= sunSetTime.hour; h++) {
      t.hour = h;
      drawMark(dc, t, length, 5);
    }
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() {}

  // Update the view
  function onUpdate(dc) {
    // Get and show the current time
    var clockTime = Sys.getClockTime();
    var timeString = Lang.format(
        "$1$:$2$", [ clockTime.hour, clockTime.min.format("%02d") ]);
    // var view = View.findDrawableById("TimeLabel");
    // view.setText(timeString);

    // Call the parent onUpdate function to redraw the layout
    // View.onUpdate(dc);

    // Clear the screen
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
    dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());

    drawHours(dc);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() {}

  // The user has just looked at their watch. Timers and animations may be
  // started here.
  function onExitSleep() {}

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() {}
}
