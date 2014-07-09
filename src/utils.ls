'use strict'

class List
  ->
    @size = 0

  add: (element) ->
    if element
      @tail = if @tail then @tail.next = { e: element } else @head = { e: element }
      @size++
    element

  poll: ->
    element = if @head then @head.e else undefined
    if element
      @head = if @head is @tail then @tail = undefined else @head.next
      @size--
    element

  remove: (element) ->
    if !element
      return false

    if @head is element
      @head = if @head is @tail then @tail = undefined else @head.next
      @size--
      return true
    node = @head.next
    while node.next.next
      if node.next is element
        node.next = node.next.next
        @size--
        return true
      node = node.next
    if @tail is element
        @tail = node
        @size--
        return true

    false

module.exports = { List }
