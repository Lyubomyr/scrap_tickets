module ScrapperHelper
  def wait_until(seconds = Capybara.default_wait_time)
    require "timeout"
    begin
      Timeout.timeout(seconds) do
        sleep(0.5) until value = yield
        value
      end
    rescue Timeout::Error
      puts "Failed at waiting for loading to appear."
      false
    end
  end

  def wait_for_animation
    wait_until do
      page.evaluate_script('$(":animated").length') == 0
    end
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_wait_time) do
      active = page.evaluate_script('jQuery.active')
      until active == 0
        active = page.evaluate_script('jQuery.active')
      end
    end
  end

  def wait_for_search
    wait_until do
      page.has_no_css?(".day-searching-message", visible: true)
    end
    puts page.has_content?("Searching...", visible: true)
    wait_until(600) do
      page.has_no_content?("Searching...", visible: true)
    end
  end
  def wait_for_autocomplite
    wait_until do
      # page.has_css?("#from-autosuggest.autosuggest li.active", visible: true)
      page.has_css?("div.ss_as > ul", visible: true)
    end
  end

  def wait_for_page_load
    wait_until do
      page.evaluate_script('document.readyState') == 'complete'
    end
  end

end