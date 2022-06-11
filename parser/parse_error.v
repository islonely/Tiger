module parser

const(
	name__eof_in_doctype = 'EOF in DOCTYPE'
	mssg__eof_in_doctype = 'This error occurs if the parser encounters the end of the input stream in a DOCTYPE.'

	name__eof_before_tag_name = 'EOF before tag name'
	mssg__eof_before_tag_name = 'This error occurs if the parser encounters the end of the input stream where a tag name is expected.'

	name__eof_in_tag = 'EOF in tag'
	mssg__eof_in_tag = 'This error occurs if the parser encounters the end of the input stream in a start tag or an end tag (e.g., <div id=).'

	name__eof_in_script_comment_like_text = 'EOF in script comment-like text'
	mssg__eof_in_script_comment_like_text = 'This error occurs if the parser encounters the end of the input stream in text that resembles an HTML comment inside script element content (e.g., <script><!-- foo).'

	name__eof_in_comment = 'EOF in comment'
	mssg__eof_in_comment = 'his error occurs if the parser encounters the end of the input stream in a comment. The parser treats such comments as if they are closed immediately before the end of the input stream.'
)

