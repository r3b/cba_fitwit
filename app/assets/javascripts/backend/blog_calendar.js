$(document).ready(function() {

    var date = new Date();
    var d = date.getDate();
    var m = date.getMonth();
    var y = date.getFullYear();
    var location_id = window.location.pathname.split("/")[3];

    $('#calendar').fullCalendar({
        editable: false,
        header: {
            left: 'prev,next today',
            center: 'title',
            right: 'month,agendaWeek,agendaDay'
        },
        defaultView: 'month',
        height: 500,
        slotMinutes: 60,

        loading: function(bool) {
            if (bool)
                $('#loading').show();
            else
                $('#loading').hide();
        },

        // a future calendar might have many sources.
        eventSources: [
            {
                url: '/backend/locations/' + location_id + '/events',
                color: 'red',
                textColor: 'white',
                ignoreTimezone: false
            },
            {
                url: '/calendar/all_camp_events/' + location_id,
                color: 'green',
                textColor: 'white',
                ignoreTimezone: false
            }
        ],

        timeFormat: 'h:mm t{ - h:mm t} ',
        dragOpacity: "0.5",
        // http://arshaw.com/fullcalendar/docs/mouse/eventClick/
        eventClick: function(event, jsEvent, view) {
            alert('test');
        }
    });

  $('#everything_calendar').fullCalendar({
        editable: false,
        header: {
            left: 'prev,next today',
            center: 'title',
            right: 'month,agendaWeek,agendaDay'
        },
        defaultView: 'month',
        height: 500,
        slotMinutes: 60,

        loading: function(bool) {
            if (bool)
                $('#loading').show();
            else
                $('#loading').hide();
        },

        // a future calendar might have many sources.
        eventSources: [
            {
                url: '/calendar/all_events/',
                color: 'blue',
                textColor: 'white',
                ignoreTimezone: false
            }
        ],

        timeFormat: 'h:mm t{ - h:mm t} ',
        dragOpacity: "0.5",
        // http://arshaw.com/fullcalendar/docs/mouse/eventClick/
        eventClick: function(event, jsEvent, view) {
            alert('test');
        }
    });
});