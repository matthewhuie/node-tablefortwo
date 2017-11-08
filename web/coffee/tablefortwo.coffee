FOURSQUARE_API_URL = 'https://api.foursquare.com/v2/'

# Returns a specific URL parameter
getURLParameter = (parameter) ->
  results = new RegExp('[\#?&]' + parameter + '=([^&#]*)').exec window.location.href
  results[1] if results? 

getSaved = (latlng, userid) ->
  $.getJSON FOURSQUARE_API_URL + 'lists/' + userid + '/todos?v=20171101&limit=1000&oauth_token=' + getURLParameter('access_token') + '&ll=' + latlng 

compareSaved = (latlng, selfUserid, otherUserid) ->
  $.when getSaved(latlng, selfUserid), getSaved(latlng, otherUserid)
    .then (selfResults, otherResults) ->
      console.log parseSaved(selfResults)
      console.log parseSaved(otherResults)
      console.log _.intersection _.pluck(parseSaved(selfResults), 'id'), _.pluck(parseSaved(otherResults), 'id')
      console.log _.filter parseSaved(selfResults), (value) ->
        _.contains _.pluck(parseSaved(otherResults), 'id'), value.id

parseSaved = (data) ->
  _.map data[0].response.list.listItems.items, (value) ->
    value.venue

# Gets the user's current location from HTML5 Geolocation
navigator.geolocation.getCurrentPosition (position) ->
  latlng = position.coords.latitude + ',' + position.coords.longitude
  compareSaved latlng, 'self', '310548'
