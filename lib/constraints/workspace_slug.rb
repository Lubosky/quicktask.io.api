module Constraints
  class WorkspaceSlug
    ALLOWED_CHARACTERS = '[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9]'.freeze
    RESERVED_SLUGS = %w[
      404
      422
      500
      502
      503
      admin
      api
      app
      application
      assets
      auth
      autocomplete
      ci
      currencies
      currency
      dashboard
      deploy
      domain
      domains
      download
      env
      explore
      feed
      files
      jwt
      language
      languages
      locale
      locales
      login
      logout
      oauth
      pages
      public
      register
      request
      requests
      rss
      search
      setup
      signin
      signout
      signup
      specialization
      specializations
      unit
      units
      upload
      user
      users
      workspace
      workspaces
    ].freeze

    def workspace_slug_regexp
      @workspace_slug_regexp ||= begin
        reserved_slugs = Regexp.new(Regexp.union(RESERVED_SLUGS).source, Regexp::IGNORECASE)

        compressed_regexp %r{
          (?!#{reserved_slugs}\Z)
          ^#{ALLOWED_CHARACTERS}$
        }x
      end
    end

    def matches?(request)
      workspace_slug = request.path_parameters[:workspace_identifier]

      return false unless workspace_slug_regexp.match? workspace_slug

      workspace_slug = workspace_slug.downcase

      Workspace.find_by(slug: workspace_slug).present?
    end

    private

    def compressed_regexp(regexp)
      Regexp.new(regexp.source.gsub(/\(\?#.+?\)/, '').gsub(/\s*/, ''), regexp.options ^ Regexp::EXTENDED).freeze
    end
  end
end
