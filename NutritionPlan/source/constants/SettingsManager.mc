using Toybox.Application;

module SettingsManager {

    const DEFAULT_FTP = 250;
    const DEFAULT_WEIGHT = 70;
    const DEFAULT_SWEAT_RATE = 900;

    const DEFAULT_CH_DOSE = 60;
    const DEFAULT_CH_THRESHOLD = 30;

    const DEFAULT_HYDRATION_DOSE = 250;
    const DEFAULT_HYDRATION_THRESHOLD = 250;

    const DEFAULT_ALERT_DURATION = 8000;

    const DEFAULT_USER_CONFIRMATION = true;

    function getFTP() {

        var value =
            Application.Properties.getValue(
                "ftp"
            );

        return (value == null || value.length() == 0)
            ? DEFAULT_FTP
            : value.toNumber();
    }

    function getWeight() {

        var value =
            Application.Properties.getValue(
                "weight"
            );

        return (value == null || value.length() == 0)
            ? DEFAULT_WEIGHT
            : value.toNumber();
    }

    function getSweatRate() {

        var value =
            Application.Properties.getValue(
                "sweatRate"
            );
        
        if (value != null && value.length() > 0) {
            return value.toNumber();
        } else {
            return null;
        }
    }

    function getCHDosePreference() {

        var value =
            Application.Properties.getValue(
                "chDosePreference"
            );

        return (value == null || value.length() == 0)
            ? DEFAULT_CH_DOSE
            : value.toNumber();
    }

    function getCHThreshold() {

        var value =
            Application.Properties.getValue(
                "chThreshold"
            );

        return (value == null || value.length() == 0)
            ? DEFAULT_CH_THRESHOLD
            : value.toNumber();
    }

    function getHydrationDosePreference() {

        var value =
            Application.Properties.getValue(
                "hydrationDosePreference"
            );

        return (value == null || value.length() == 0)
            ? DEFAULT_HYDRATION_DOSE
            : value.toNumber();
    }

    function getHydrationThreshold() {

        var value =
            Application.Properties.getValue(
                "hydrationThreshold"
            );

        return (value == null || value.length() == 0)
            ? DEFAULT_HYDRATION_THRESHOLD
            : value.toNumber();
    }

    function getAlertDisplayingTimer() {

        var value =
            Application.Properties.getValue(
                "alertDisplayingTimer"
            );

        return (value == null || value.length() == 0)
            ? DEFAULT_ALERT_DURATION
            : value.toNumber() * 1000;
    }
}