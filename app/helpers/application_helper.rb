module ApplicationHelper
  def render_rich_text(text)
    return '' if text.blank?

    pipeline_context = {
      file_ext: 'png',
      gfm: true,
      link_attr: 'target="_blank"'
    }
    pipeline = HTML::Pipeline.new [
      HTML::Pipeline::MarkdownFilter,
      HTML::Pipeline::SanitizationFilter,
      HTML::Pipeline::TwemojiFilter,
      HTML::Pipeline::AutolinkFilter
    ], pipeline_context
    pipeline.call(text)[:output].to_s.html_safe
  end
end
