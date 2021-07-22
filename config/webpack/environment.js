const { environment } = require('@rails/webpacker')

// jQuery を追加する
const webpack = require('webpack')
environment.plugins.prepend('Provide',
    new webpack.ProvidePlugin({
        $: 'jquery/src/jquery',
        jQuery: 'jquery/src/jquery'
    })
)
// jQuery を追加ここまで

module.exports = environment
