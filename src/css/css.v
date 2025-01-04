module css

pub struct Stylesheet {
pub mut:
	rulesets      []Ruleset
	media_queries []MediaQuery
}

pub enum Importance {
	normal
	important
}

pub struct MediaQuery {
pub mut:
	query    string
	rulesets []Ruleset
}

pub struct Variable {
pub mut:
	name  string
	value string
}

pub struct Ruleset {
pub mut:
	selector      string
	media_queries []MediaQuery
	variables     []Variable
}
