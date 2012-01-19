$(document).ready ->
  $("#vet_status_changer").hide()
  $("#vet_status").click ->
    $("#vet_status_changer").dialog
      autoOpen: false
      show: "blind"
      hide: "explode"
      resizable: false
      width: 900
      modal: true
      title: "Change your FitWit history"

    $("#vet_status_changer").dialog "open"
    false

  $("#has_physician_approval").change ->
    app_div = $('#has_physician_approval_explanation')
    (if ($(this).val() is "Yes") then app_div.hide() else app_div.show())

  $("#meds_affect_vital_signs").change ->
    vital_div = $('#meds_affect_vital_signs_explanation')
    (if ($(this).val() is "Yes") then vital_div.hide() else vital_div.show())
