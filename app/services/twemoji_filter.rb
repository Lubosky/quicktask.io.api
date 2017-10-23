class TwemojiFilter < HTML::Pipeline::Filter
  def call
    Twemoji.parse(
      doc,
      file_ext:   context[:file_ext]   || 'svg',
      class_name: context[:class_name] || 'emoji'
    )
  end
end
