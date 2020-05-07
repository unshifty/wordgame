module.exports = {
  purge: [
    './src/**/*.html',
    './src/**/*.vue',
    './src/**/*.jsx',
  ],
  theme: {
    extend: {
      boxShadow: {
        blue: '0 5px 12px 0px rgba(66, 153, 225, 0.4);',
        red: '0 5px 12px 0px rgba(225, 66, 66, 0.4);'
      }
    },
  },
  variants: {},
  plugins: [
    require('@tailwindcss/custom-forms')
  ],
}
