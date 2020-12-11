//= require select2

function update_state(region, done) {
  'use strict'
  var region = ''
  // var country = $('span#' + region + 'country .select2').select2('val')
  var country = $('span#' + region + 'country .select2 option:selected').val()
  console.log('country', country)
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
      stateSelect.prop('disabled', false).show()
      // stateSelect.select2()
      stateInput.hide().prop('disabled', true)
    } else {
      stateInput.prop('disabled', false).show()
      stateSelect.select2('destroy').hide()
    }

    if (done) done()
  })
}

$(document).ready(function () {
  $('span#country .select2').on('change', function () { update_state(''); });
  // $('#spree_vendor_stock_location_country_id').change(function () {
  //   let country_id = parseInt($('#spree_vendor_stock_location_country_id option:selected').val())
  //   update_state('', function () {
  //     let state_id = parseInt($('#spree_vendor_stock_location_state_id option:selected').val())
  //     console.log('state_id ' + state_id)
  //     $('#spree_vendor_stock_location_state_id').select2('val', state_id)
  //   })
  // })
  // $('#spree_vendor_stock_location_country_id').change(function () {
  //   let country_id = parseInt($('#spree_vendor_stock_location_country_id option:selected').val())
  //   console.log('country id ' + country_id)
  //   $('#spree_vendor_stock_location_country_id').select2('val', country_id).promise().done(function () {
  //     update_state('', function () {
  //       let state_id = parseInt($('#spree_vendor_stock_location_state_id option:selected').val())
  //       console.log('state_id ' + state_id)
  //       $('#spree_vendor_stock_location_state_id').select2('val', state_id)
  //     })
  //   })
  // })
});
