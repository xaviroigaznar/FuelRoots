using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Application;
using Toybox.Activity;

using Session;
using UI;

class FuelHydrationField extends WatchUi.DataField {

    var sessionManager;
    var renderer;

    var ftp;
    var weight;

    function initialize() {

        DataField.initialize();

        renderer = new UI.UIRenderer();

        ftp = Application.getApp().getProperty("ftp");
        weight = Application.getApp().getProperty("weight");

        if (ftp == null) {
            ftp = 250;
        }

        if (weight == null) {
            weight = 75;
        }

        var profile = new Session.AthleteProfile(ftp, weight);

        sessionManager = new Session.SessionManager(profile);
    }

    function onUpdate(dc) {
        var info = Activity.getActivityInfo();

        // Feed Garmin info directly
        sessionManager.update(info);

        var state = sessionManager.getState();

        drawMainScreen(dc, state);
    }


    function drawMainScreen(dc, state) {

        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();

        var cardHeight = height / 3;

        // ==================================================
        // FUEL CARD
        // ==================================================

        var fuelMain = "--";
        var fuelSecondary = "Calculating";

        if (state.timeToDepletion != null) {
            fuelMain = state.timeToDepletion;
        }

        if (state.fuelStateLabel != null) {
            fuelSecondary = state.fuelStateLabel;
        }

        renderer.drawMetricCard(
            dc,
            0,
            0,
            width,
            cardHeight,
            Graphics.COLOR_BLUE,
            "FUEL LEFT",
            fuelMain,
            fuelSecondary
        );

        // ==================================================
        // HYDRATION CARD
        // ==================================================

        var hydrationMain = "--";
        var hydrationSecondary = "No deficit";

        if (state.minutesUntilDrink != null) {
            hydrationMain = "Drink in " + state.drinkCountdownLabel;
        }

        if (state.hydrationDeficitMl != null) {
            hydrationSecondary = Utils.FormatUtils.formatMilliliters(state.hydrationDeficitMl) + " deficit";
        }

        renderer.drawMetricCard(
            dc,
            0,
            cardHeight,
            width,
            cardHeight,
            Graphics.COLOR_BLUE,
            "HYDRATION",
            hydrationMain,
            hydrationSecondary
        );

        // ==================================================
        // STATUS CARD
        // ==================================================

        var statusMain = "STABLE";
        var statusSecondary = "Fatigue 0%";

        if (state.statusLabel != null) {
            statusMain = state.statusLabel;
        }

        if (state.fatiguePercent != null) {
            statusSecondary = "Fatigue " + Utils.FormatUtils.formatPercent(state.fatiguePercent);
        }

        var statusColor = Graphics.COLOR_GREEN;

        if (state.fatiguePercent != null) {

            if (state.fatiguePercent > 70) {
                statusColor = Graphics.COLOR_RED;
            }
            else if (state.fatiguePercent > 40) {
                statusColor = Graphics.COLOR_ORANGE;
            }
        }

        renderer.drawMetricCard(
            dc,
            0,
            cardHeight * 2,
            width,
            cardHeight,
            statusColor,
            "STATUS",
            statusMain,
            statusSecondary
        );
    }
}