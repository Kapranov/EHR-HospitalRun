module ApplicationHelper
  def week_days
    [
        { abbr: 'M',  name: 'monday'    },
        { abbr: 'T',  name: 'tuesday'   },
        { abbr: 'W',  name: 'wednesday' },
        { abbr: 'Th', name: 'thursday'  },
        { abbr: 'F',  name: 'friday'    },
        { abbr: 'Sa', name: 'saturday'  },
        { abbr: 'Su', name: 'sunday'    },
    ]
  end

  def paginate(collection, params= {})
    will_paginate collection, params.merge(:renderer => RemoteLinkPaginationHelper::LinkRenderer)
  end

  def render_messages
    flash_array = []
    if flash.present?
      flash.each do |type, message|
        type_template = type.include?('_more') ? 1 : 0
        if message.is_a?(String)
          flash_array << render(partial: 'layouts/messages', locals: { type: type, type_template: type_template, message: message })
        else
          if message.present? && message.is_a?(Array)
            message.each do |m|
              flash_array << render(partial: 'layouts/messages', locals: { type: type, type_template: type_template, message: message }) unless m.blank?
            end
          end
        end
      end
    end
    flash_array.join('').html_safe
  end
end
