//= require select2

function update_state(region, done) {
  'use strict'
  // var country = $('span#' + region + 'country .select2').select2('val')
  var country = $('span#' + region + 'country .select2 option:selected').val()
  var stateSelect = $('span#' + region + 'state select.select2')
  var stateInput = $('span#' + region + 'state input.state_name')

  $.get(Spree.routes.states_search + '?country_id=' + country, function (data) {
    var states = data.states

    if (states.length > 0) {
      stateSelect.html('')
      var statesWithBlank = [{
        name: '',
        id: ''
      }].concat(states)
      $.each(statesWithBlank, function (pos, state) {
        var opt = $(document.createElement('option'))
          .prop('value', state.id)
          .html(state.name)
        stateSelect.append(opt)
      })
      stateSelect.prop('disabled', false).attr('required', true).show()
      // stateSelect.select2()
      stateInput.hide().attr('required', false).prop('disabled', true)
    } else {
      stateInput.attr('required', true).prop('disabled', false).show()
      stateSelect.attr('required', false).select2('destroy').hide()
    }

    if (done) done()
  })
}

$(document).on('ready turbolinks:load', function () {
  $('span#country .select2').on('change', function () { update_state(''); });
})
