import { useEffect, useState } from 'react'
import type { FormEvent } from 'react'
import './App.css'

type TabKey = 'nutrition' | 'activities' | 'history'

type FoodItem = {
  id: string
  name: string
  serving: string
  calories: number
  protein: number
  carbs: number
  fat: number
}

type FoodEntry = {
  id: string
  foodId: string
  date: string
  servings: number
}

type SportProfile = {
  id: string
  name: string
  stats: string[]
}

type ActivityEntry = {
  id: string
  sportId: string
  date: string
  notes: string
  stats: Record<string, string>
}

type AppState = {
  foods: FoodItem[]
  foodEntries: FoodEntry[]
  sports: SportProfile[]
  activityEntries: ActivityEntry[]
}

type FoodDraft = {
  name: string
  serving: string
  calories: string
  protein: string
  carbs: string
  fat: string
}

type LogDraft = {
  foodId: string
  servings: string
}

type SportDraft = {
  name: string
  stats: string
}

const storageKey = 'desktop-fitness-tracker-state'

const today = new Date().toISOString().slice(0, 10)

const defaultState: AppState = {
  foods: [
    {
      id: 'food-oats',
      name: 'Oats Bowl',
      serving: '1 bowl',
      calories: 320,
      protein: 18,
      carbs: 42,
      fat: 9,
    },
    {
      id: 'food-chicken',
      name: 'Chicken Rice Plate',
      serving: '1 plate',
      calories: 540,
      protein: 41,
      carbs: 48,
      fat: 19,
    },
  ],
  foodEntries: [
    { id: 'entry-1', foodId: 'food-oats', date: today, servings: 1 },
    { id: 'entry-2', foodId: 'food-chicken', date: today, servings: 1 },
  ],
  sports: [
    {
      id: 'sport-running',
      name: 'Running',
      stats: ['Distance (km)', 'Duration (min)', 'Pace'],
    },
    {
      id: 'sport-strength',
      name: 'Strength',
      stats: ['Exercise', 'Sets', 'Reps', 'Load (kg)'],
    },
  ],
  activityEntries: [
    {
      id: 'activity-1',
      sportId: 'sport-running',
      date: today,
      notes: 'Evening session',
      stats: {
        'Distance (km)': '6.2',
        'Duration (min)': '34',
        Pace: '5:29 /km',
      },
    },
  ],
}

function createId(prefix: string) {
  return `${prefix}-${Math.random().toString(36).slice(2, 10)}`
}

function loadState(): AppState {
  const raw = localStorage.getItem(storageKey)

  if (!raw) {
    return defaultState
  }

  try {
    return JSON.parse(raw) as AppState
  } catch {
    return defaultState
  }
}

function App() {
  const [appState, setAppState] = useState<AppState>(() => loadState())
  const [selectedDay, setSelectedDay] = useState(today)
  const [activeTab, setActiveTab] = useState<TabKey>('nutrition')
  const [statusMessage, setStatusMessage] = useState('Desktop mode ready. All data stays local on this computer.')
  const [foodDraft, setFoodDraft] = useState<FoodDraft>({
    name: '',
    serving: '',
    calories: '',
    protein: '',
    carbs: '',
    fat: '',
  })
  const [logDraft, setLogDraft] = useState<LogDraft>({ foodId: '', servings: '1' })
  const [sportDraft, setSportDraft] = useState<SportDraft>({ name: '', stats: '' })
  const [activityDraft, setActivityDraft] = useState({
    sportId: '',
    notes: '',
    stats: {} as Record<string, string>,
  })

  useEffect(() => {
    localStorage.setItem(storageKey, JSON.stringify(appState))
  }, [appState])

  const dayFoodEntries = appState.foodEntries
    .filter((entry) => entry.date === selectedDay)
    .map((entry) => ({
      ...entry,
      food: appState.foods.find((food) => food.id === entry.foodId),
    }))
    .filter((entry) => entry.food)

  const nutritionTotals = dayFoodEntries.reduce(
    (totals, entry) => {
      totals.calories += entry.food!.calories * entry.servings
      totals.protein += entry.food!.protein * entry.servings
      totals.carbs += entry.food!.carbs * entry.servings
      totals.fat += entry.food!.fat * entry.servings
      return totals
    },
    { calories: 0, protein: 0, carbs: 0, fat: 0 },
  )

  const selectedSport = appState.sports.find((sport) => sport.id === activityDraft.sportId)

  const dayActivities = appState.activityEntries
    .filter((entry) => entry.date === selectedDay)
    .map((entry) => ({
      ...entry,
      sport: appState.sports.find((sport) => sport.id === entry.sportId),
    }))
    .filter((entry) => entry.sport)

  const groupedDays = Array.from(
    new Set([
      ...appState.foodEntries.map((entry) => entry.date),
      ...appState.activityEntries.map((entry) => entry.date),
    ]),
  ).sort((left, right) => right.localeCompare(left))

  function saveFood(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()

    if (!foodDraft.name || !foodDraft.serving) {
      setStatusMessage('Food name and serving are required.')
      return
    }

    const nextFood: FoodItem = {
      id: createId('food'),
      name: foodDraft.name.trim(),
      serving: foodDraft.serving.trim(),
      calories: Number(foodDraft.calories),
      protein: Number(foodDraft.protein),
      carbs: Number(foodDraft.carbs),
      fat: Number(foodDraft.fat),
    }

    if (Object.values(nextFood).some((value) => typeof value === 'number' && Number.isNaN(value))) {
      setStatusMessage('Nutrition values must be valid numbers.')
      return
    }

    setAppState((current) => ({
      ...current,
      foods: [nextFood, ...current.foods],
    }))
    setFoodDraft({ name: '', serving: '', calories: '', protein: '', carbs: '', fat: '' })
    setLogDraft((current) => ({ foodId: current.foodId || nextFood.id, servings: current.servings }))
    setStatusMessage(`Saved ${nextFood.name} to your food library.`)
  }

  function logFood(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()

    if (!logDraft.foodId) {
      setStatusMessage('Choose a food before logging it.')
      return
    }

    const servings = Number(logDraft.servings)

    if (!Number.isFinite(servings) || servings <= 0) {
      setStatusMessage('Servings must be greater than zero.')
      return
    }

    setAppState((current) => ({
      ...current,
      foodEntries: [
        {
          id: createId('food-entry'),
          foodId: logDraft.foodId,
          date: selectedDay,
          servings,
        },
        ...current.foodEntries,
      ],
    }))
    setLogDraft((current) => ({ ...current, servings: '1' }))
    setStatusMessage('Meal added to the selected day.')
  }

  function saveSport(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()

    const stats = sportDraft.stats
      .split(',')
      .map((value) => value.trim())
      .filter(Boolean)

    if (!sportDraft.name.trim() || stats.length === 0) {
      setStatusMessage('A sport name and at least one statistic are required.')
      return
    }

    const nextSport: SportProfile = {
      id: createId('sport'),
      name: sportDraft.name.trim(),
      stats,
    }

    setAppState((current) => ({
      ...current,
      sports: [nextSport, ...current.sports],
    }))
    setSportDraft({ name: '', stats: '' })
    setActivityDraft({ sportId: nextSport.id, notes: '', stats: {} })
    setStatusMessage(`Saved ${nextSport.name} with ${stats.length} custom fields.`)
  }

  function saveActivity(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()

    if (!selectedSport) {
      setStatusMessage('Choose a sport profile before saving an activity.')
      return
    }

    const missingStat = selectedSport.stats.find((stat) => !activityDraft.stats[stat]?.trim())
    if (missingStat) {
      setStatusMessage(`Fill in ${missingStat} before saving the activity.`)
      return
    }

    setAppState((current) => ({
      ...current,
      activityEntries: [
        {
          id: createId('activity'),
          sportId: selectedSport.id,
          date: selectedDay,
          notes: activityDraft.notes.trim(),
          stats: activityDraft.stats,
        },
        ...current.activityEntries,
      ],
    }))
    setActivityDraft({ sportId: selectedSport.id, notes: '', stats: {} })
    setStatusMessage(`Activity saved for ${selectedSport.name}.`)
  }

  function removeFood(id: string) {
    setAppState((current) => ({
      ...current,
      foods: current.foods.filter((food) => food.id !== id),
      foodEntries: current.foodEntries.filter((entry) => entry.foodId !== id),
    }))
    setStatusMessage('Food removed from the library and daily logs.')
  }

  function removeSport(id: string) {
    setAppState((current) => ({
      ...current,
      sports: current.sports.filter((sport) => sport.id !== id),
      activityEntries: current.activityEntries.filter((entry) => entry.sportId !== id),
    }))
    setActivityDraft({ sportId: '', notes: '', stats: {} })
    setStatusMessage('Sport profile removed with its linked activities.')
  }

  function removeActivity(id: string) {
    setAppState((current) => ({
      ...current,
      activityEntries: current.activityEntries.filter((entry) => entry.id !== id),
    }))
    setStatusMessage('Activity removed from history.')
  }

  function renderHistoryDay(date: string) {
    const foods = appState.foodEntries
      .filter((entry) => entry.date === date)
      .map((entry) => ({
        ...entry,
        food: appState.foods.find((food) => food.id === entry.foodId),
      }))
      .filter((entry) => entry.food)

    const activities = appState.activityEntries
      .filter((entry) => entry.date === date)
      .map((entry) => ({
        ...entry,
        sport: appState.sports.find((sport) => sport.id === entry.sportId),
      }))
      .filter((entry) => entry.sport)

    return (
      <article className="history-card" key={date}>
        <div className="history-header">
          <div>
            <p className="eyebrow">{date}</p>
            <h3>{foods.length} meals, {activities.length} sessions</h3>
          </div>
          <button type="button" className="ghost-button" onClick={() => setSelectedDay(date)}>
            Focus day
          </button>
        </div>
        <div className="history-grid">
          <div>
            <h4>Nutrition</h4>
            {foods.length === 0 ? <p className="muted">No meals saved.</p> : null}
            {foods.map((entry) => (
              <div className="history-row" key={entry.id}>
                <span>{entry.food!.name}</span>
                <span>{entry.servings} x {entry.food!.serving}</span>
              </div>
            ))}
          </div>
          <div>
            <h4>Activities</h4>
            {activities.length === 0 ? <p className="muted">No sessions saved.</p> : null}
            {activities.map((entry) => (
              <div className="history-stack" key={entry.id}>
                <div className="history-row">
                  <span>{entry.sport!.name}</span>
                  <button type="button" className="text-button" onClick={() => removeActivity(entry.id)}>
                    Delete
                  </button>
                </div>
                <p className="muted">{Object.entries(entry.stats).map(([key, value]) => `${key}: ${value}`).join(' • ')}</p>
              </div>
            ))}
          </div>
        </div>
      </article>
    )
  }

  return (
    <div className="app-shell">
      <header className="hero-panel">
        <div>
          <p className="eyebrow">Desktop fitness tracker</p>
          <h1>Train, eat, and review from one local workspace.</h1>
          <p className="hero-copy">
            This desktop version keeps your food library, daily nutrition, sport-specific stats, and activity history directly on your computer.
          </p>
        </div>
        <div className="hero-metrics">
          <div>
            <span className="metric-value">{appState.foods.length}</span>
            <span className="metric-label">foods saved</span>
          </div>
          <div>
            <span className="metric-value">{appState.sports.length}</span>
            <span className="metric-label">sports tracked</span>
          </div>
          <div>
            <span className="metric-value">{appState.activityEntries.length}</span>
            <span className="metric-label">sessions logged</span>
          </div>
        </div>
      </header>

      <section className="toolbar-panel">
        <div className="tab-strip" role="tablist" aria-label="Fitness sections">
          {[
            { key: 'nutrition', label: 'Nutrition' },
            { key: 'activities', label: 'Activities' },
            { key: 'history', label: 'History' },
          ].map((tab) => (
            <button
              key={tab.key}
              type="button"
              className={activeTab === tab.key ? 'tab active' : 'tab'}
              onClick={() => setActiveTab(tab.key as TabKey)}
            >
              {tab.label}
            </button>
          ))}
        </div>
        <label className="date-picker">
          <span>Selected day</span>
          <input type="date" value={selectedDay} onChange={(event) => setSelectedDay(event.target.value)} />
        </label>
      </section>

      <p className="status-banner">{statusMessage}</p>

      {activeTab === 'nutrition' ? (
        <main className="content-grid">
          <section className="panel card-stack">
            <div className="section-heading">
              <div>
                <p className="eyebrow">Food library</p>
                <h2>Create reusable food cards</h2>
              </div>
            </div>
            <form className="editor-grid" onSubmit={saveFood}>
              <input value={foodDraft.name} onChange={(event) => setFoodDraft((current) => ({ ...current, name: event.target.value }))} placeholder="Food name" />
              <input value={foodDraft.serving} onChange={(event) => setFoodDraft((current) => ({ ...current, serving: event.target.value }))} placeholder="Default serving" />
              <input value={foodDraft.calories} onChange={(event) => setFoodDraft((current) => ({ ...current, calories: event.target.value }))} placeholder="Calories" inputMode="decimal" />
              <input value={foodDraft.protein} onChange={(event) => setFoodDraft((current) => ({ ...current, protein: event.target.value }))} placeholder="Protein" inputMode="decimal" />
              <input value={foodDraft.carbs} onChange={(event) => setFoodDraft((current) => ({ ...current, carbs: event.target.value }))} placeholder="Carbs" inputMode="decimal" />
              <input value={foodDraft.fat} onChange={(event) => setFoodDraft((current) => ({ ...current, fat: event.target.value }))} placeholder="Fat" inputMode="decimal" />
              <button type="submit" className="primary-button">Save food</button>
            </form>
            <div className="list-stack">
              {appState.foods.map((food) => (
                <article className="item-card" key={food.id}>
                  <div>
                    <h3>{food.name}</h3>
                    <p className="muted">{food.serving}</p>
                  </div>
                  <div className="macro-row">
                    <span>{food.calories} kcal</span>
                    <span>{food.protein}p</span>
                    <span>{food.carbs}c</span>
                    <span>{food.fat}f</span>
                  </div>
                  <button type="button" className="text-button" onClick={() => removeFood(food.id)}>
                    Remove
                  </button>
                </article>
              ))}
            </div>
          </section>

          <section className="panel card-stack">
            <div className="section-heading">
              <div>
                <p className="eyebrow">Daily log</p>
                <h2>Log meals for {selectedDay}</h2>
              </div>
            </div>
            <form className="editor-grid compact" onSubmit={logFood}>
              <select value={logDraft.foodId} onChange={(event) => setLogDraft((current) => ({ ...current, foodId: event.target.value }))}>
                <option value="">Choose a food</option>
                {appState.foods.map((food) => (
                  <option key={food.id} value={food.id}>
                    {food.name}
                  </option>
                ))}
              </select>
              <input value={logDraft.servings} onChange={(event) => setLogDraft((current) => ({ ...current, servings: event.target.value }))} placeholder="Servings" inputMode="decimal" />
              <button type="submit" className="primary-button">Add meal</button>
            </form>

            <div className="stats-grid">
              <article className="stat-card">
                <span className="stat-label">Calories</span>
                <strong>{nutritionTotals.calories.toFixed(0)}</strong>
              </article>
              <article className="stat-card">
                <span className="stat-label">Protein</span>
                <strong>{nutritionTotals.protein.toFixed(0)} g</strong>
              </article>
              <article className="stat-card">
                <span className="stat-label">Carbs</span>
                <strong>{nutritionTotals.carbs.toFixed(0)} g</strong>
              </article>
              <article className="stat-card">
                <span className="stat-label">Fat</span>
                <strong>{nutritionTotals.fat.toFixed(0)} g</strong>
              </article>
            </div>

            <div className="list-stack">
              {dayFoodEntries.length === 0 ? <p className="muted">No meals recorded for this date yet.</p> : null}
              {dayFoodEntries.map((entry) => (
                <article className="item-card" key={entry.id}>
                  <div>
                    <h3>{entry.food!.name}</h3>
                    <p className="muted">{entry.servings} x {entry.food!.serving}</p>
                  </div>
                  <div className="macro-row">
                    <span>{(entry.food!.calories * entry.servings).toFixed(0)} kcal</span>
                    <span>{(entry.food!.protein * entry.servings).toFixed(0)}p</span>
                    <span>{(entry.food!.carbs * entry.servings).toFixed(0)}c</span>
                    <span>{(entry.food!.fat * entry.servings).toFixed(0)}f</span>
                  </div>
                </article>
              ))}
            </div>
          </section>
        </main>
      ) : null}

      {activeTab === 'activities' ? (
        <main className="content-grid">
          <section className="panel card-stack">
            <div className="section-heading">
              <div>
                <p className="eyebrow">Sport profiles</p>
                <h2>Define custom activity fields</h2>
              </div>
            </div>
            <form className="editor-grid compact" onSubmit={saveSport}>
              <input value={sportDraft.name} onChange={(event) => setSportDraft((current) => ({ ...current, name: event.target.value }))} placeholder="Sport name" />
              <input value={sportDraft.stats} onChange={(event) => setSportDraft((current) => ({ ...current, stats: event.target.value }))} placeholder="Stats separated by commas" />
              <button type="submit" className="primary-button">Save sport</button>
            </form>

            <div className="list-stack">
              {appState.sports.map((sport) => (
                <article className="item-card" key={sport.id}>
                  <div>
                    <h3>{sport.name}</h3>
                    <p className="muted">{sport.stats.join(' • ')}</p>
                  </div>
                  <button type="button" className="text-button" onClick={() => removeSport(sport.id)}>
                    Remove
                  </button>
                </article>
              ))}
            </div>
          </section>

          <section className="panel card-stack">
            <div className="section-heading">
              <div>
                <p className="eyebrow">Activity log</p>
                <h2>Record a session for {selectedDay}</h2>
              </div>
            </div>
            <form className="editor-grid" onSubmit={saveActivity}>
              <select value={activityDraft.sportId} onChange={(event) => setActivityDraft({ sportId: event.target.value, notes: '', stats: {} })}>
                <option value="">Choose a sport</option>
                {appState.sports.map((sport) => (
                  <option key={sport.id} value={sport.id}>
                    {sport.name}
                  </option>
                ))}
              </select>
              <textarea value={activityDraft.notes} onChange={(event) => setActivityDraft((current) => ({ ...current, notes: event.target.value }))} placeholder="Session notes" rows={3} />
              {selectedSport?.stats.map((stat) => (
                <input
                  key={stat}
                  value={activityDraft.stats[stat] ?? ''}
                  onChange={(event) =>
                    setActivityDraft((current) => ({
                      ...current,
                      stats: {
                        ...current.stats,
                        [stat]: event.target.value,
                      },
                    }))
                  }
                  placeholder={stat}
                />
              ))}
              <button type="submit" className="primary-button">Save activity</button>
            </form>

            <div className="list-stack">
              {dayActivities.length === 0 ? <p className="muted">No sessions recorded for this date yet.</p> : null}
              {dayActivities.map((entry) => (
                <article className="item-card" key={entry.id}>
                  <div>
                    <h3>{entry.sport!.name}</h3>
                    <p className="muted">{entry.notes || 'No session note'}</p>
                  </div>
                  <div className="stat-pills">
                    {Object.entries(entry.stats).map(([key, value]) => (
                      <span key={key}>{key}: {value}</span>
                    ))}
                  </div>
                  <button type="button" className="text-button" onClick={() => removeActivity(entry.id)}>
                    Remove
                  </button>
                </article>
              ))}
            </div>
          </section>
        </main>
      ) : null}

      {activeTab === 'history' ? (
        <main className="history-layout">
          <section className="panel card-stack">
            <div className="section-heading">
              <div>
                <p className="eyebrow">Timeline</p>
                <h2>Review progress by day</h2>
              </div>
            </div>
            {groupedDays.length === 0 ? <p className="muted">History will appear once you log meals or activities.</p> : null}
            {groupedDays.map(renderHistoryDay)}
          </section>
        </main>
      ) : null}
    </div>
  )
}

export default App
