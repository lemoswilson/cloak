###
Query for all Contentful pages given an array of contentTypes
###
path = require 'path'
memoize = require 'lodash/memoize'
flatten = require 'lodash/flatten'
upperFirst = require 'lodash/upperFirst'
{ getEntries } = require '../services/contentful'
{ isGenerating } = require '../config/utils'

# Make the list of routes
module.exports = memoize (pageTypes) ->
	return [] unless isGenerating and pageTypes.length
	routes = []

	# Loop through types and fetch their routes
	console.log('ℹ Fetching SSG data')
	for pageType in pageTypes
		results = await getEntries query: makeQuery pageType

		# Make the list of routes
		routes = [
			...routes,
			...flatten(results).map (entry) ->

				# Craft used the `__home__` slug for the homepage
				route: pageType.route entry[pageType.routeField || 'slug']

				# Return the seo robots aray
				robots: entry.seo?.robots || []
		]

	# Return final routes
	console.log('✔ Fetched SSG data')
	return routes

# GQL to get all the entries of a page
makeQuery = ({ contentType, routeField = 'slug' }) ->
	"""
	query {
		#{contentType}Collection {
			items {
				... on #{upperFirst(contentType)} {
					#{routeField}
					seo { robots }
				}
			}
		}
	}
	"""
