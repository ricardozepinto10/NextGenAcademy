<script setup>
import { shallowRef, onMounted } from 'vue';
import { ScheduleXCalendar } from '@schedule-x/vue'
import {
  createCalendar,
  createViewDay,
  createViewMonthAgenda,
  createViewMonthGrid,
  createViewWeek,
} from '@schedule-x/calendar'
import '@schedule-x/theme-default/dist/index.css'
import { supabase } from '@/supabase'

const formatTime = (timeStr) => {
  const [hours, minutes] = timeStr.split(':');
  return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`;
};

const fetchEvents = async () => {
  const { data, error } = await supabase
    .from('trainings')
    .select('*');

  if (error) {
    console.error("Error fetching events:", error);
    return [];
  }

  return data.map(event => {
    const formattedStart = formatDateForDisplay(event.start_datetime);
    const formattedEnd = formatDateForDisplay(event.end_datetime);

    return {
      id: event.id,
      title: event.description || 'No title',
      start: formattedStart,
      end: formattedEnd,
    };
  });
};


const formatDateForDisplay = (isoDate) => {
  const date = new Date(isoDate);
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  const hours = String(date.getHours()).padStart(2, '0');
  const minutes = String(date.getMinutes()).padStart(2, '0');

  return `${year}-${month}-${day} ${hours}:${minutes}`;
};


const calculateTimeRange = (events) => {
  const times = events
    .map(event => [
      event.start.split(' ')[1] || '00:00',
      event.end.split(' ')[1] || '23:59'
    ])
    .flat()
    .sort();

  const start = times[0] || '00:00';
  const end = times[times.length - 1] || '23:59';

  // Extend the time range to ensure you can see the hour before and after
  const adjustedStart = start > '00:00' ? formatTime(`${parseInt(start.split(':')[0]) - 1}:00`) : '00:00';
  const adjustedEnd = end < '23:59' ? formatTime(`${parseInt(end.split(':')[0]) + 1}:00`) : '23:59';

  return {
    start: adjustedStart,
    end: adjustedEnd,
  };
};

const calendarApp = shallowRef(null);  // Use shallowRef to avoid deep reactivity
const events = ref([]); // Initialize events as a ref

// Fetch events after the component is mounted
onMounted(async () => {
  const fetchedEvents = await fetchEvents();

  events.value = fetchedEvents;

  const timeRange = calculateTimeRange(fetchedEvents);

  // Now create the calendar with the fetched events and time range
  calendarApp.value = createCalendar({
    locale: 'pt-PT',
    weekOptions: {
      gridHeight: 600,
    },
    dayBoundaries: timeRange,
    views: [
      createViewDay(),
      createViewWeek(),
      createViewMonthGrid(),
      createViewMonthAgenda(),
    ],
    events: fetchedEvents,
  });
});
</script>

<template>
  <div class="sx-vue-calendar-wrapper">
    <!-- Make sure to use shallowRef object here -->
    <ScheduleXCalendar v-if="calendarApp" :calendar-app="calendarApp" />
  </div>
</template>
