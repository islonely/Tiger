module dom

// https://html.spec.whatwg.org/multipage/links.html#htmlhyperlinkelementutils
struct HTMLHyperlinkElementUtils {
pub:
	origin string
pub mut:
	protocol string
	username string
	password string
	host string
	hostname string
	port string
	pathname string
	search string
	hash string
}