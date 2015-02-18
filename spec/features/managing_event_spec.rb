require 'rails_helper'

feature 'Event Editing' do
  let!(:venue) { create(:venue) }
  let!(:locked_event) { create(:event,locked: true, venue: venue) }

  background do
    Timecop.travel('2014-10-09')
    create :event, title: 'Ruby Future', start_time: today
  end

  after do
    Timecop.return
  end

  scenario 'A user edits an existing event' do
    visit '/'

    within '#today' do
      click_on 'Ruby Future'
    end

    click_on 'edit'

    expect(find_field('Event Name').value).to have_content 'Ruby Future'
    fill_in 'Event Name', with: 'Ruby ABCs'
    fill_in 'start_date', with: '2014-10-10'
    fill_in 'start_time', with: '06:00 PM'
    fill_in 'end_date', with: '2014-10-10'
    fill_in 'end_time', with: '07:00 PM'
    fill_in 'Website', with: 'www.rubynewbies.com'
    fill_in 'Description', with: 'An event for beginners'
    fill_in 'Tags', with: 'beginners,ruby'
    click_on 'Update Event'

    expect(page).to have_content 'Event was successfully saved'
    expect(page).to have_content 'Ruby ABCs'
    expect(page).to have_content 'Friday, October 10, 2014 from 6–7pm'
    expect(page).to have_content 'Website http://www.rubynewbies.com'
    expect(page).to have_content 'Description An event for beginners'
    expect(page).to have_content 'Tags beginners, ruby'

    click_on 'Calagator'
    within '#tomorrow' do
      expect(page).to have_content 'Ruby ABCs'
    end
  end

  scenario 'Edit a locked event with key' do
    visit "/events/#{locked_event.id}/edit/?key=#{locked_event.key}"

    fill_in 'Website', with: 'www.example.com'
    fill_in 'Description', with: 'An event for women'
    fill_in 'Tags', with: 'ruby'
    click_on 'Update Event'

    expect(page).to have_content 'Event was successfully saved'
    expect(page).to have_content 'An event for women'
    expect(page).to have_content 'Website http://www.example.com'
    expect(page).to have_content 'Description An event for women'
    expect(page).to have_content 'ruby'
  end

  scenario 'Edit a locked even without key' do
    visit "/events/#{locked_event.id}/edit/"

    expect(page).to have_content('You are not permitted to modify this event')
  end
end


feature 'Event Cloning' do
  background do
    Timecop.travel('2014-10-09')
    create :event, title: 'Ruby Event Part One', start_time: today + 4.day
  end

  after do
    Timecop.return
  end

  scenario 'A user clones an existing event' do
    visit '/'

    within '#next_two_weeks' do
      click_on 'Ruby Event Part One'
    end
    click_on 'clone'

    expect(find_field('Event Name').value).to have_content 'Ruby Event Part One'

    fill_in 'Event Name', with: 'Ruby Event Part Two'
    fill_in 'start_date', with: '2014-10-27'
    fill_in 'start_time', with: '06:00 PM'
    fill_in 'end_time', with: '11:00 PM'
    fill_in 'end_date', with: '2014-27-13'
    fill_in 'Website', with: 'www.rubynewbies.com'
    fill_in 'Description', with: 'An event for beginners'
    fill_in 'Tags', with: 'beginners,ruby'
    click_on 'Create Event'

    expect(page).to have_content 'Event was successfully saved'
    expect(page).to have_content 'Ruby Event Part Two'
    expect(page).to have_content 'Monday, October 27, 2014 at 6pm'
    expect(page).to have_content 'Website http://www.rubynewbies.com'
    expect(page).to have_content 'Description An event for beginners'
    expect(page).to have_content 'Tags beginners, ruby'

    click_on 'Calagator'
    click_on 'View future events »'
    expect(page).to have_content 'Ruby Event Part Two'
  end
end

feature 'Event Deletion' do
  let!(:venue) { create(:venue) }
  let!(:locked_event) { create(:event, title: 'Locked Event Title', locked: true, venue: venue) }

  background do
    create :event, title: 'Ruby and You', start_time: today + 1.day
  end

  scenario 'A user deletes an event' do
    visit '/'

    within '#tomorrow' do
      click_on 'Ruby and You'
    end

    click_on 'delete'

    expect(page).to have_content '"Ruby and You" has been deleted'

    click_on 'Calagator'
    within '#tomorrow' do
      expect(page).to have_content '- No events -'
    end
  end

  scenario 'A user deletes a locked event' do
    pending
    visit "/events/#{locked_event.id}/edit/?key=#{locked_event.key}"
    click_on 'delete'

    expect(page).to have_content '"Locked Event Title" has been deleted'
  end
end
