using Toybox.Time.Gregorian as Calendar;
using Toybox.Test as Test;

module Astro {
  const JD_1970_01_01 = 2440587.5;

  //! Return the Julian date corresponding to a given Moment
  //! @param [Moment] when  Date+Time expressed as a Moment for which we want
  //!                       the JD
  function julian_date(when) {
    var jd = when.value().toFloat() / Calendar.SECONDS_PER_DAY.toFloat() +
             JD_1970_01_01;
    return jd;
  }

  ( : test) function test_julian_date(logger) {
    // Some random dates in the present, past and future
    var m1 = Calendar.moment({:year=>2016, :month=>11, :day=>04, :hour=>04, :minute=>41, :second=>00 });
    var m2 = Calendar.moment({:year=>1970, :month=>05, :day=>23, :hour=>10, :minute=>11, :second=>12 });
    // var m3 = Calendar.moment({:year=>2054, :month=>09, :day=>06, :hour=>06,
    // :minute=>00, :second=>00 });
    var times = [
      [ m1, 1478234460, 2457696.695139 ],  // 2016-11-04_04:41:00 GMT
      [ m2, 12305472, 2440729.924444 ],    // 1970-05-23_10:11:12 GMT
      [ m2, 267237360, 971448.750000 ]     // 2054-09-07_06:00:00 GMT
    ];
    for (var i = 0; i < times.size(); i++) {
      var ue = times[i][0].value();
      var jd = julian_date(times[i][0]);
      logger.debug(ue + " = " + times[i][1] + " -> " + times[i][2] + " = " +
                   jd);
      Test.assertEqualMessage(ue, times[i][1],
                              "Unix epoch does not match for time #" + (i + 1));
      Test.assertEqualMessage(
          jd, times[i][2], "Julian date does not match for time #" + (i + 1));
    }
    return true;
  }
}
