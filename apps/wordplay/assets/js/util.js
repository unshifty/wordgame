
var show = function (elem) {
	elem.style.display = 'block'
}

var hide = function (elem) {
	elem.style.display = 'none'
}

var toggle = function (elem) {
	if (window.getComputedStyle(elem).display !== 'none') {
		hide(elem)
  }
  else {
    show(elem)
  }
}

// Listen for click events
document.addEventListener('click', function (event) {
	// Make sure clicked element is our toggle
	if (!event.target.classList.contains('toggle')) return
  
  // Prevent default link behavior
	event.preventDefault()
	// Get the content
	var content = document.querySelector(event.target.hash);
	if (!content) return

	// Toggle the content
	toggle(content)

}, false);