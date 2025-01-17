require "capybara"
require "capybara/dsl"
require "byebug"
require "chronic"

class Scheduler

  include Capybara::DSL

  def schedule_basement(user, day, month, time)
    # select URL
    Capybara.app_host = 'https://basement-boulderstudio.de/'

    # visit website
    visit("/booking")

    # select regular slots (after 14 or weekends)
    find(".drp-course-list-item-regulaere-slots").click

    # advance month if needed
    month_diff = month - Date.today.month
    month_diff.times do
      find('.drp-course-month-selector-next').click
    end

    # click day
    find(".drp-calendar-day.drp-calendar-day-dates", text: day).click # only if the correct month is already selected

    # click book button on chosen time
    find(".drp-course-date-item", text: time).find_button(text: "Buchen").click

    # fill in user data
    fill_in("Vorname*", with: user["name"])
    fill_in("Nachname*", with: user["last_name"])
    fill_in("Geburtsdatum* (TT.MM.JJJJ)", with: user["birthday"])
    fill_in("Straße und Hausnummer*", with: user["address"])
    fill_in("Postleitzahl*", with: user["postal_code"])
    fill_in("Stadt*", with: user["city"])
    fill_in("Mobilnummer*", with: user["phone_number"])
    fill_in("Email*", with: user["email"])
    select(user["type"])
    fill_in("Mitgliedsnummer USC*", with: user["usc_number"])

    # click submit button
    find(".drp-course-booking-continue").click

    # accept data protection terms
    find("label.drp-d-block").click

    byebug

    # submit form
    find("button.drp-booking-overview-booking-btn").click
  end

  def schedule_boulderklub(user, day, month, time)
    # select URL
    Capybara.app_host = 'https://boulderklub.de'

    # visit website
    visit("/")

    # advance month if needed
    month_diff = month - Date.today.month
    month_diff.times do
      find('.drp-course-month-selector-next').click
    end

    # click day
    find('.drp-calendar-day', :text => /\A#{day}\z/).click # only works if the correct month is already selected

    # click book button on chosen time
    find(".drp-course-date-item", text: time).find_button(text: "BUCHEN").click

    # fill in user data
    fill_in("Vorname*", with: user["name"])
    fill_in("Nachname*", with: user["last_name"])
    fill_in("Geburtsdatum* (TT.MM.JJJJ)", with: user["birthday"])
    fill_in("Straße und Hausnummer*", with: user["address"])
    fill_in("Postleitzahl*", with: user["postal_code"])
    fill_in("Stadt*", with: user["city"])
    fill_in("Mobilnummer*", with: user["phone_number"])
    fill_in("Email*", with: user["email"])
    select(user["type"])
    fill_in("Mietgliedsnummer USC*", with: user["usc_number"])

    # click submit button
    find(".drp-course-booking-continue").click

    # accept data protection terms
    find("label.drp-d-block").click

    byebug

    # submit form
    find("button.drp-booking-overview-booking-btn").click
  end
end

def configure_capybara
  Capybara.default_driver = :selenium
  Capybara.run_server = false
end

def load_user
  YAML.load(File.read("data/user.yml"))
end

# read arguments
gym_name = ARGV[0]
human_date = ARGV[1]
time = ARGV[2]

# calculate day
date = Chronic.parse(human_date)
day = date.day.to_s
month = date.month

configure_capybara

# load user data
user = load_user

# schedule
if gym_name == "basement"
  Scheduler.new.schedule_basement(user, day, month, time)
elsif gym_name == "boulderklub"
  Scheduler.new.schedule_boulderklub(user, day, month, time)
end
