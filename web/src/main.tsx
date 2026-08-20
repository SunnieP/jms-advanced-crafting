import React, { useEffect, useMemo, useState } from 'react';
import { createRoot } from 'react-dom/client';
import './styles.css';

type Requirement = { item: string; amount: number; owned: number; consume: boolean };
type Result = { item_name: string; amount: number };
type Recipe = {
  id: number;
  slug: string;
  label: string;
  description: string;
  category: string;
  craftTime: number;
  globalXp: number;
  categoryXp: number;
  requiredGlobalLevel: number;
  requiredCategoryLevel: number;
  ingredients: Requirement[];
  tools: Requirement[];
  results: Result[];
  player: { global: { global_level: number }; category: { level: number } };
};
type Session = { benchId: string; recipes: Recipe[] };

const resource = typeof (window as any).GetParentResourceName === 'function'
  ? (window as any).GetParentResourceName()
  : 'jms_crafting';

async function nui<T>(event: string, data: unknown = {}): Promise<T> {
  const response = await fetch(`https://${resource}/${event}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data)
  });
  return response.json();
}

function itemLabel(item: string) {
  return item.replaceAll('_', ' ').replace(/\w/g, char => char.toUpperCase());
}

function App() {
  const [open, setOpen] = useState(false);
  const [session, setSession] = useState<Session | null>(null);
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const [crafting, setCrafting] = useState(false);
  const [notice, setNotice] = useState('');

  useEffect(() => {
    const onMessage = (event: MessageEvent) => {
      const { type, payload } = event.data || {};
      if (type === 'crafting:open') {
        setSession(payload);
        setSelectedId(payload.recipes?.[0]?.id ?? null);
        setOpen(true);
        setCrafting(false);
        setNotice('');
      }
      if (type === 'crafting:close') setOpen(false);
      if (type === 'crafting:result') {
        setCrafting(false);
        setNotice(payload.ok ? 'Craft complete. Meta Glasses added to inventory.' : `Craft failed: ${payload.reason || 'unknown error'}`);
      }
    };
    window.addEventListener('message', onMessage);
    return () => window.removeEventListener('message', onMessage);
  }, []);

  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape' && open && !crafting) close();
    };
    window.addEventListener('keydown', onKeyDown);
    return () => window.removeEventListener('keydown', onKeyDown);
  });

  const selected = useMemo(() => session?.recipes.find(recipe => recipe.id === selectedId) ?? null, [session, selectedId]);
  const canCraft = !!selected
    && selected.player.global.global_level >= selected.requiredGlobalLevel
    && selected.player.category.level >= selected.requiredCategoryLevel
    && [...selected.ingredients, ...selected.tools].every(entry => entry.owned >= entry.amount);

  async function close() {
    await nui('crafting:close');
    setOpen(false);
  }

  async function startCraft() {
    if (!selected || crafting) return;
    const result = await nui<{ ok: boolean; reason?: string; duration?: number }>('crafting:start', { recipeId: selected.id });
    if (!result.ok) {
      setNotice(`Unable to craft: ${result.reason || 'requirements not met'}`);
      return;
    }
    setCrafting(true);
    setNotice(`Assembling ${selected.label}…`);
  }

  if (!open || !session) return null;

  return (
    <main className="crafting-shell">
      <section className="crafting-window">
        <header className="topbar">
          <div>
            <p className="eyebrow">JMS / FIELD CRAFTING</p>
            <h1>Public Tech Workbench</h1>
          </div>
          <button className="icon-button" onClick={close} disabled={crafting} aria-label="Close crafting">ESC</button>
        </header>

        <div className="workspace">
          <aside className="sidebar">
            <p className="section-label">Categories</p>
            <button className="category active"><span>◈</span><span>Electronics</span><small>LVL 02</small></button>
            <div className="profile-card">
              <p className="section-label">Global craft</p>
              <strong>Level 03</strong>
              <div className="progress"><i style={{ width: '44%' }} /></div>
              <span>Workshop certification</span>
            </div>
          </aside>

          <section className="recipe-panel">
            <div className="panel-heading">
              <div>
                <p className="section-label">Electronics</p>
                <h2>Available schematics</h2>
              </div>
              <span>{session.recipes.length.toString().padStart(2, '0')} recipes</span>
            </div>
            <div className="recipe-grid">
              {session.recipes.map(recipe => {
                const recipeReady = recipe.player.global.global_level >= recipe.requiredGlobalLevel
                  && recipe.player.category.level >= recipe.requiredCategoryLevel
                  && [...recipe.ingredients, ...recipe.tools].every(entry => entry.owned >= entry.amount);
                return (
                  <button key={recipe.id} className={`recipe-card ${selected?.id === recipe.id ? 'selected' : ''}`} onClick={() => setSelectedId(recipe.id)}>
                    <div className="schematic-mark">◎</div>
                    <p>{recipe.label}</p>
                    <small>{Math.round(recipe.craftTime / 1000)} SEC <b>·</b> +{recipe.categoryXp} XP</small>
                    <em className={recipeReady ? 'ready' : 'locked'}>{recipeReady ? 'Ready' : 'Requirements'}</em>
                  </button>
                );
              })}
            </div>
          </section>

          <aside className="detail-panel">
            {selected && <>
              <div className="detail-title">
                <p className="section-label">{selected.category}</p>
                <h2>{selected.label}</h2>
                <p>{selected.description}</p>
              </div>

              <div className="blueprint-visual">
                <span>◎</span>
                <i>REFURBISHED TECH</i>
              </div>

              <section className="requirements">
                <p className="section-label">Requirements</p>
                <div className="requirement-row"><span>Global Crafting</span><b>{selected.player.global.global_level} / {selected.requiredGlobalLevel}</b></div>
                <div className="requirement-row"><span>Electronics</span><b>{selected.player.category.level} / {selected.requiredCategoryLevel}</b></div>
              </section>

              <section className="requirements">
                <p className="section-label">Consumed materials</p>
                {selected.ingredients.map(entry => <div className="requirement-row" key={entry.item}><span>{itemLabel(entry.item)}</span><b className={entry.owned >= entry.amount ? '' : 'missing'}>{entry.owned} / {entry.amount}</b></div>)}
              </section>

              <section className="requirements">
                <p className="section-label">Required tools</p>
                {selected.tools.map(entry => <div className="requirement-row" key={entry.item}><span>{itemLabel(entry.item)} <small>Not consumed</small></span><b className={entry.owned >= entry.amount ? '' : 'missing'}>{entry.owned} / {entry.amount}</b></div>)}
              </section>

              <div className="output-row"><span>Output</span><b>{selected.results.map(result => `${itemLabel(result.item_name)} ×${result.amount}`).join(', ')}</b></div>
              <div className="craft-meta">{Math.round(selected.craftTime / 1000)} seconds <i /> +{selected.globalXp} global XP <i /> +{selected.categoryXp} electronics XP</div>
              {notice && <p className="notice">{notice}</p>}
              <button className="craft-button" onClick={startCraft} disabled={!canCraft || crafting}>{crafting ? 'Crafting…' : canCraft ? `Craft ${selected.label}` : 'Requirements not met'}</button>
            </>}
          </aside>
        </div>
      </section>
    </main>
  );
}

createRoot(document.getElementById('root')!).render(<App />);
