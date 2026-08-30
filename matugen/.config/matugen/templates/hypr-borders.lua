hl.config({
    general = {
        col = {
            active_border = {
                colors = {
                    "rgba({{colors.primary.default.hex_stripped}}ff)",
                    "rgba({{colors.secondary.default.hex_stripped}}ff)"
                },
                angle = 45,
            },

            inactive_border = "rgba({{colors.outline.default.hex_stripped}}aa)",
        },
    },
})