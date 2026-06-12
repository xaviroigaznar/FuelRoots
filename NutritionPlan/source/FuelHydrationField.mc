using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Application;
using Toybox.Activity;
using Toybox.System;

using Session;
using UI;

class FuelHydrationField extends WatchUi.DataField {
    // =====================================
    // CORE
    // =====================================
    var sessionManager;
    var renderer;

    // =====================================
    // ATHLETE CONFIG
    // =====================================
    var ftp;
    var weight;

    // =====================================
    // INIT
    // =====================================
    function initialize() {

        DataField.initialize();

        renderer = new UI.UIRenderer();

        // =============================
        // SETTINGS
        // =============================
        ftp = Application.getApp().getProperty("ftp");
        weight = Application.getApp().getProperty("weight");

        if (ftp == null) {
            ftp = 250;
        }

        if (weight == null) {
            weight = 75;
        }

        // =============================
        // PROFILE
        // =============================
        var profile = new Session.AthleteProfile(ftp, weight);

        sessionManager = new Session.SessionManager(profile);
    }

    function onUpdate(dc) {
        var info = Activity.getActivityInfo();

        // Feed Garmin info directly
        sessionManager.update(info);

        // State
        var state = sessionManager.getState();

        // Draw UI
        drawMainScreen(dc, state);
    }

    function drawMainScreen(dc, state) {

        dc.clear();

        // =================================
        // DASHBOARD
        // =================================
        renderer.drawMainDashboard(dc, state);

        // =================================
        // ALERTS
        // =================================
        if (state.activeAlert != Constants.AlertType.NONE && state.activeAlert != null) {
            renderer.drawAlertScreen(
                dc,
                state
            );
        }
    }
}