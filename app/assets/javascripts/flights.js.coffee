# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
showLoading = ->
  loading = $("img.loading")
  wrapper = loading.parent()
  left = wrapper.width() / 2 - 30
  top = wrapper.height() / 2 - 30
  loading.css('left', left)
  loading.css('top', top)
  loading.show()

hideLoading = ->
  $("img.loading").hide()

$ ->
  $("input#search_button").click =>
    # showLoading()