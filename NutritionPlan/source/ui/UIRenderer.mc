// ======================================================
// UIRenderer.mc
// ======================================================

module UI {

    using Toybox.Graphics;

    class UIRenderer {

        function initialize() {
        }

        // =====================================
        // ALERT OVERLAY
        // =====================================
        function drawAlertOverlay(
            dc,
            title,
            message,
            color
        ) {

            var width =
                dc.getWidth();

            var height =
                dc.getHeight();

            // =============================
            // OVERLAY SIZE
            // =============================

            var w = width - 30;
            var h = 90;

            var x = 15;
            var y = (height / 2) - (h / 2);

            // =============================
            // SHADOW
            // =============================

            dc.setColor(
                Graphics.COLOR_DK_GRAY,
                Graphics.COLOR_DK_GRAY
            );

            dc.fillRectangle(
                x + 3,
                y + 3,
                w,
                h
            );

            // =============================
            // MAIN BOX
            // =============================

            dc.setColor(
                Graphics.COLOR_BLACK,
                Graphics.COLOR_BLACK
            );

            dc.fillRectangle(
                x,
                y,
                w,
                h
            );

            // =============================
            // BORDER
            // =============================

            dc.setColor(
                color,
                Graphics.COLOR_BLACK
            );

            dc.drawRectangle(
                x,
                y,
                w,
                h
            );

            // =============================
            // HEADER
            // =============================

            dc.fillRectangle(
                x,
                y,
                w,
                24
            );

            dc.setColor(
                Graphics.COLOR_WHITE,
                color
            );

            dc.drawText(
                x + (w / 2),
                y + 4,
                Graphics.FONT_SMALL,
                title,
                Graphics.TEXT_JUSTIFY_CENTER
            );

            // =============================
            // MESSAGE
            // =============================

            dc.setColor(
                Graphics.COLOR_WHITE,
                Graphics.COLOR_BLACK
            );

            dc.drawText(
                x + (w / 2),
                y + 38,
                Graphics.FONT_MEDIUM,
                message,
                Graphics.TEXT_JUSTIFY_CENTER
            );

            // =============================
            // FOOTER
            // =============================

            dc.drawText(
                x + (w / 2),
                y + 65,
                Graphics.FONT_XTINY,
                "PRESS START",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }

        function drawMainDashboard(
        dc,
        state
        ) {

            dc.clear();

            var width = dc.getWidth();
            var height = dc.getHeight();

            var tanksHeight =
                Math.floor(height * 0.5);

            var countdownHeight =
                Math.floor(height * 0.2);

            var statusHeight =
                height
                - tanksHeight
                - countdownHeight;
            // =====================================
            // TANKS
            // =====================================

            drawNutritionTanks(
                dc,
                state,
                0,
                5,
                width,
                tanksHeight
            );

            // =====================================
            // COUNTDOWNS
            // =====================================

            drawCountdownSection(
                dc,
                state,
                0,
                tanksHeight + 10,
                width,
                countdownHeight
            );

            // =====================================
            // STATUS
            // =====================================

            drawStatusSection(
                dc,
                state,
                0,
                tanksHeight + countdownHeight + 20,
                width,
                statusHeight
            );
        }

        function drawNutritionTanks(
        dc,
        state,
        x,
        y,
        width,
        height
        ) {

            var tankWidth =
                (width / 2) - 10;

            drawTank(
                dc,
                x + 5,
                y,
                tankWidth,
                height,
                "CHO (g)",
                state.carbsBurnedSinceLastFuel,
                state.CARBS_THRESHOLD,
                Graphics.COLOR_GREEN,
                Graphics.COLOR_GREEN
            );

            drawTank(
                dc,
                x + tankWidth + 15,
                y,
                tankWidth,
                height,
                "H2O (ml)",
                state.fluidLostSinceLastDrink,
                state.HYDRATION_THRESHOLD,
                Graphics.COLOR_BLUE,
                Graphics.COLOR_BLUE
            );
        }

        function drawTank(
        dc,
        x,
        y,
        width,
        height,
        title,
        deficitValue,
        maxValue,
        fillColor,
        borderColor
        ) {
            var tankColor = fillColor;
            var ratio = 0.0;
            var remaining = maxValue - deficitValue;
            if (remaining <= 0) {
                remaining = 0;
            }

            if (maxValue > 0) {
                ratio = 1 - (deficitValue / maxValue);
            }

            if (ratio > 1.0) {
                ratio = 1.0;
            }

            if (ratio < 0.0) {
                ratio = 0.0;
            }

            if (ratio <= 0.2) {

                tankColor = Graphics.COLOR_RED;

            } else if (ratio <= 0.5) {

                tankColor = Graphics.COLOR_ORANGE;

            } else if (ratio <= 0.67) {

                tankColor = Graphics.COLOR_YELLOW;
            }

            // Marco
            dc.setColor(borderColor, Graphics.COLOR_TRANSPARENT);

            dc.drawRoundedRectangle(
                x,
                y,
                width,
                height,
                10
            );

            // Título
            dc.drawText(
                x + width / 2,
                y + 5,
                Graphics.FONT_TINY,
                title,
                Graphics.TEXT_JUSTIFY_CENTER
            );

            // =========================
            // Nivel
            // =========================

            // Fondo
            dc.setColor(
                tankColor,
                tankColor
            );

            dc.fillRectangle(
                x + 5,
                y + 25,
                width - 10,
                height - 30
            );

            // Relleno
            var emptyHeight = (height - 30) * (1.0 - ratio);

            dc.setColor(
                Graphics.COLOR_DK_GRAY,
                Graphics.COLOR_DK_GRAY
            );

            dc.fillRectangle(
                x + 5,
                y + 25,
                width - 10,
                emptyHeight
            );

            // Valor
            dc.setColor(
                Graphics.COLOR_WHITE,
                Graphics.COLOR_TRANSPARENT
            );

            dc.drawText(
                x + width / 2,
                y + height / 2,
                Graphics.FONT_LARGE,
                remaining.toNumber(),
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }

        function drawCountdownSection(
        dc,
        state,
        x,
        y,
        width,
        height
        ) {

            dc.setColor(
                Graphics.COLOR_BLACK,
                Graphics.COLOR_TRANSPARENT
            );

            // -------------------------
            // Fuel
            // -------------------------

            dc.drawText(
                x + 10,
                y,
                Graphics.FONT_MEDIUM,
                "FUEL "
                + state.recommendedCarbs.format("%.0f")
                + "g IN "
                + state.nextFuelCountdownLabel,
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + 10,
                y + 25,
                Graphics.FONT_SMALL,
                "Total taken "
                + state.sessionCarbsIngested.format("%.0f")
                + "g",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            // -------------------------
            // Drink
            // -------------------------

            dc.drawText(
                x + 10,
                y + 50,
                Graphics.FONT_MEDIUM,
                "DRINK "
                + state.recommendedDrink.format("%.0f")
                + "ml IN "
                + state.nextDrinkCountdownLabel,
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + 10,
                y + 75,
                Graphics.FONT_SMALL,
                + "Total drunk "
                + state.sessionHydrationDrunk.format("%.0f")
                + "ml",
                Graphics.TEXT_JUSTIFY_LEFT
            );
        }

        function drawStatusSection(
        dc,
        state,
        x,
        y,
        width,
        height
        ) {

            var color =
                Graphics.COLOR_GREEN;

            if (state.bonkRisk > 60) {

                color =
                    Graphics.COLOR_RED;

            } else if (
                state.bonkRisk > 30
            ) {

                color =
                    Graphics.COLOR_ORANGE;
            }

            dc.setColor(
                color,
                Graphics.COLOR_TRANSPARENT
            );

            dc.drawText(
                width / 2,
                y,
                Graphics.FONT_LARGE,
                state.statusLabel,
                Graphics.TEXT_JUSTIFY_CENTER
            );

            dc.setColor(
                Graphics.COLOR_BLACK,
                Graphics.COLOR_TRANSPARENT
            );

            dc.drawText(
                width / 2,
                y + 40,
                Graphics.FONT_SMALL,
                "Fatigue "
                + state.fatiguePercent
                + " • Bonk risk "
                + state.bonkRisk.format("%.0f")
                + "%",
                Graphics.TEXT_JUSTIFY_CENTER
            );

            dc.drawText(
                width / 2,
                y + 70,
                Graphics.FONT_SMALL,
                "Bonk time "
                + state.bonkTimeLabel,
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }

        function drawAlertScreen(
            dc,
            state
        ) {

            var width = dc.getWidth();
            var height = dc.getHeight();

            var bgColor;
            var actionText;
            var amountText;
            var unitText;
            var detailText;

            switch (state.activeAlert) {

                case Constants.AlertType.DRINK:

                    bgColor = Graphics.COLOR_BLUE;

                    actionText = "DRINK";

                    amountText =
                        state.recommendedDrink
                        .format("%.0f");

                    unitText = "ml";

                    detailText =
                        amountText
                        + "ml WATER";

                    break;

                case Constants.AlertType.FUEL:

                    bgColor =
                        Graphics.COLOR_ORANGE;

                    actionText = "FUEL";

                    amountText =
                        state.recommendedCarbs
                        .format("%.0f");

                    unitText = "g";

                    detailText =
                        amountText
                        + "g CARBS";

                    break;

                default:
                    return;
            }

            // ============================
            // Background
            // ============================

            dc.setColor(
                Graphics.COLOR_WHITE,
                bgColor
            );

            dc.fillRectangle(
                0,
                0,
                width,
                height
            );

            // ============================
            // Circle
            // ============================

            var circleRadius = height / 6;

            var circleX =
                width / 2;

            var circleY =
                height / 4;

            dc.setColor(
                Graphics.COLOR_WHITE,
                Graphics.COLOR_WHITE
            );

            dc.fillCircle(
                circleX,
                circleY,
                circleRadius + 4
            );

            dc.setColor(
                Graphics.COLOR_BLACK,
                Graphics.COLOR_BLACK
            );

            dc.fillCircle(
                circleX,
                circleY,
                circleRadius
            );

            // ============================
            // Action
            // ============================

            dc.setColor(
                Graphics.COLOR_WHITE,
                Graphics.COLOR_TRANSPARENT
            );

            dc.drawText(
                circleX,
                circleY - 35,
                Graphics.FONT_SMALL,
                actionText,
                Graphics.TEXT_JUSTIFY_CENTER
            );

            // ============================
            // Amount
            // ============================

            dc.drawText(
                circleX,
                circleY - 5,
                Graphics.FONT_NUMBER_HOT,
                amountText,
                Graphics.TEXT_JUSTIFY_CENTER
            );

            dc.drawText(
                circleX,
                circleY + 35,
                Graphics.FONT_MEDIUM,
                unitText,
                Graphics.TEXT_JUSTIFY_CENTER
            );

            // ============================
            // Description box
            // ============================

            var boxWidth =
                width * 0.75;

            var boxHeight =
                55;

            var boxX =
                (width - boxWidth) / 2;

            var boxY =
                circleY
                + circleRadius
                + 25;

            dc.setColor(
                Graphics.COLOR_BLACK,
                Graphics.COLOR_WHITE
            );

            dc.fillRectangle(
                boxX,
                boxY,
                boxWidth,
                boxHeight
            );

            dc.drawRectangle(
                boxX,
                boxY,
                boxWidth,
                boxHeight
            );

            dc.drawText(
                width / 2,
                boxY + 12,
                Graphics.FONT_MEDIUM,
                detailText,
                Graphics.TEXT_JUSTIFY_CENTER
            );

            // ============================
            // Footer
            // ============================

            dc.setColor(
                Graphics.COLOR_WHITE,
                Graphics.COLOR_TRANSPARENT
            );

            dc.drawText(
                width / 2,
                height - 25,
                Graphics.FONT_XTINY,
                "NutritionPlan",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }
    }
}