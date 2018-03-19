# frozen_string_literal: true

module Contributions
  class Delete < ApplicationPresenter

    def content
      mustache[:content] ||= begin
        {
          title: t('title') + ' - ' + @contribution.display_title,
          confirmation_text: [t('delete_1', scope: 'contribute.contributions.confirm'), t('delete_2', scope: 'contribute.contributions.confirm')]
        }
      end
    end

    def page_content_heading
      t(:title)
    end

    def form
      @view.render partial: 'delete'
    end

    protected

    def t(*args, **options)
      super(*args, options.reverse_merge(scope: 'contribute.pages.contributions.delete'))
    end
  end
end
