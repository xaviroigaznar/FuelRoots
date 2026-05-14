// ======================================================
// UIRenderer.mc
// ======================================================

module UI {

    using Toybox.Graphics;

    class UIRenderer {

        function initialize() {
        }

        function drawMetricCard(
            dc,
            x,
            y,
            w,
            h,
            color,
            title,
            primaryValue,
            secondaryValue
        ) {

            // Background
            dc.setColor(
                Graphics.COLOR_BLACK,
                Graphics.COLOR_BLACK
            );

            dc.fillRectangle(x, y, w, h);

            // Border
            dc.setColor(
                color,
                Graphics.COLOR_BLACK
            );

            dc.drawRectangle(x, y, w, h);

            // Top header line
            dc.fillRectangle(x, y, w, 18);

            // Header text
            dc.setColor(
                Graphics.COLOR_WHITE,
                color
            );

            dc.drawText(
                x + 8,
                y + 2,
                Graphics.FONT_XTINY,
                title,
                Graphics.TEXT_JUSTIFY_LEFT
            );

            // Main value
            dc.setColor(
                Graphics.COLOR_WHITE,
                Graphics.COLOR_BLACK
            );

            dc.drawText(
                x + (w / 2),
                y + (h / 2) - 12,
                Graphics.FONT_NUMBER_MEDIUM,
                primaryValue,
                Graphics.TEXT_JUSTIFY_CENTER
            );

            // Secondary value
            dc.drawText(
                x + (w / 2),
                y + (h / 2) + 50,
                Graphics.FONT_XTINY,
                secondaryValue,
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }
    }
}