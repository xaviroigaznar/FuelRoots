module Utils {

    using Toybox.Math;

    class FormatUtils {

        // ==========================================
        // TIME FORMATTING
        // ==========================================

        // Converts minutes (float) to MM:SS
        //
        // Example:
        // 12.5 -> 12:30
        //
        static function formatCountdown(minutesValue) {

            if (minutesValue == null) {
                return "--:--";
            }

            var totalSeconds =
                (minutesValue * 60).toNumber();

            if (totalSeconds < 0) {
                totalSeconds = 0;
            }

            var minutes =
                Math.floor(totalSeconds / 60);

            var seconds =
                totalSeconds % 60;

            return
                minutes.format("%d")
                + "m"
                + seconds.format("%02d")
                + "s";
        }

        // Converts seconds to HH:MM:SS
        //
        // Example:
        // 3661 -> 1:01:01
        //
        static function formatDuration(secondsValue) {

            if (secondsValue == null) {
                return "--:--";
            }

            var totalSeconds =
                secondsValue.toNumber();

            var hours =
                Math.floor(totalSeconds / 3600);

            var minutes =
                Math.floor((totalSeconds % 3600) / 60);

            var seconds =
                totalSeconds % 60;

            if (hours > 0) {

                return
                    hours.format("%d")
                    + "h"
                    + minutes.format("%02d")
                    + "m"
                    + seconds.format("%02d")
                    + "s";
            }

            return
                minutes.format("%d")
                + "m"
                + seconds.format("%02d")
                + "s";
        }

        // ==========================================
        // PERCENTAGE
        // ==========================================

        static function formatPercent(value) {

            if (value == null || value <= 0) {
                return "--%";
            }

            return value.format("%.0f") + "%";
        }

        // ==========================================
        // ML / LITERS
        // ==========================================

        static function formatMilliliters(value) {

            if (value == null) {
                return "-- ml";
            }

            return value.format("%.0f") + "ml";
        }

        static function formatLiters(value) {

            if (value == null) {
                return "--.-L";
            }

            return value.format("%.1f") + "L";
        }

        // ==========================================
        // POWER
        // ==========================================

        static function formatWatts(value) {

            if (value == null) {
                return "--w";
            }

            return value.format("%.0f") + "w";
        }

        // ==========================================
        // TEMPERATURE
        // ==========================================

        static function formatTemperature(value) {

            if (value == null) {
                return "--°";
            }

            return value.format("%.0f") + "°";
        }

        // ==========================================
        // DISTANCE
        // ==========================================

        static function formatKilometers(value) {

            if (value == null) {
                return "--.-km";
            }

            return value.format("%.1f") + "km";
        }
    }
}