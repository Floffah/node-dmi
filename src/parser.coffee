nearley = require 'nearley'
grammar = require './grammar'

parse = (size, data) ->
	p = new nearley.Parser grammar.ParserRules, grammar.ParserStart

	p.feed data

	process size, p.results[0]

process = (size, data) ->
	tileSize =
		width: 32
		height: 32

	if data.size.width? and data.size.height?
		tileSize =
			width: Number data.size.width[0]
			height: Number data.size.height[0]

	sizeTiles =
		width: size.width / tileSize.width
		height: size.height / tileSize.height

	frameIndex = 0
	{
		version: data.version
		size, tileSize
		states:	for {name, properties} in data.states

			directions = Number properties.dirs?[0] ? 1
			frameCount = Number properties.frames?[0] ? 1
			delays = (Number e for e in (properties.delay ? [1]))
			movement = properties.movement?[0] is '1'

			frames = getFrames sizeTiles, tileSize, frameIndex, frameCount, directions, delays

			frameIndex += frameCount * directions

			{name, frames, movement}
	}

getFrames = ({width}, tileSize, startOffset, count, directions, delays) ->
	for dir in [0...directions]
		for i in [0...count]
			offset = startOffset + i*directions + dir

			{
				offset:
					x: offset %% width * tileSize.width
					y: offset // width * tileSize.height

				delay: delays[i] * 100 # delays are in 1/10th seconds, convert to ms
			}

module.exports = {parse}