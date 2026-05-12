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

        var boxWidth = width;
        var boxHeight = height / 3;

        // =========================
        // FUEL
        // =========================
        renderer.drawMetricBox(
            dc,
            0,
            0,
            boxWidth,
            boxHeight,
            Graphics.COLOR_BLUE,
            "FUEL",
            (state.glycogenEstimate == null ? 0 : state.glycogenEstimate).format("%.0f") + "%",
            ""
        );

        // =========================
        // HYDRATION
        // =========================
        renderer.drawMetricBox(
            dc,
            0,
            boxHeight,
            boxWidth,
            boxHeight,
            Graphics.COLOR_BLUE,
            "HYDRATION",
            (state.fluidLossTotal == null ? 0 : state.fluidLossTotal).format("%.1f") + "L",
            ""
        );

        // =========================
        // BONK RISK
        // =========================
        renderer.drawBottomBox(
            dc,
            0,
            boxHeight * 2,
            boxWidth,
            boxHeight,
            Graphics.COLOR_RED,
            "BONK RISK",
            (state.bonkRisk == null ? 0 : state.bonkRisk)
        );
    }
}