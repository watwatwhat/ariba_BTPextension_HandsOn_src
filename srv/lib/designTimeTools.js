function console_log_color(message, color) {
    const consoleColor_red = '\u001b[31m';
    const consoleColor_blue = '\u001b[34m';
    const consoleColor_yellow = '\u001b[33m';
    const consoleColor_reset = '\u001b[0m';
    switch (color) {
        case "red":
            console.log(consoleColor_red + message + consoleColor_reset);
            return;
        case "blue":
            console.log(consoleColor_blue + message + consoleColor_reset);
            return;
        case "yellow":
            console.log(consoleColor_yellow + message + consoleColor_reset);
            return;
        default:
            console.log(message);
            return;
    }
}

function getCorrelationID() {
    return Math.random().toString(32).substring(2);
}

module.exports = {
    console_log_color,
    getCorrelationID
};