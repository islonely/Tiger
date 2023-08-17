module dom

// https://html.spec.whatwg.org/multipage/nav-history-apis.html#location
pub struct Location {
	origin string
	protocol string
	host string
	hostname string
	port string
	pathname string
	search string
	hash string
	ancestor_origins []string
}