// ============================================================================
// theme-studio-app.js — UI state, rendering, wiring for GCPS Theme Studio
// Depends on palette-data.js + theme-studio.js (window.TS)
// ============================================================================
(function(){
const T = window.TS;
const $ = s => document.querySelector(s);
const $$ = s => Array.from(document.querySelectorAll(s));
const cap = s => s.charAt(0).toUpperCase()+s.slice(1);
const clamp=(x,a,b)=>Math.min(b,Math.max(a,x));

const state = {
  tab:"palette",
  // palette
  mode:"bases", baseKey:"teal", cluster:"Brookwood", school:SCHOOL_ORDER[0],
  type:"sequential", catSet:"curated", perfN:4, perfV:"semantic",
  counts:{sequential:5,continuous:9,categorical:7,diverging:7},
  // typography
  font:"sourcesans", baseSize:15, ratio:"1.2", weight:600,
  // surfaces
  surface:"paper", accent:"maroon",
  // export
  exp:"r"
};

/* ---------- palette helpers ---------- */
const TYPES=[["sequential","Sequential"],["tints","Tints & Shades"],["diverging","Diverging"],["categorical","Categorical"],["performance","Performance"],["continuous","Continuous"],["trend","Trend"]];
const PURPOSE={sequential:"Single-hue ramp, light → dark. Ordered data, KPI emphasis, table heat.",tints:"11-step tint/shade scale (50–950) for fine UI theming and surface layering.",diverging:"Two-ended scale through a neutral center — above/below target, gap-to-goal, change.",categorical:"Distinct hues for unrelated groups. Three curated, source-independent sets.",performance:"Ordinal proficiency scale. Semantic = fixed good→needs-support; Source-tinted = monochrome intensity.",continuous:"Fine gradient for heatmaps and continuous fills (low → high).",trend:"Fixed semantic indicators — positive, negative, neutral."};
const DIVERGE_PAIR_={maroon:"teal",teal:"maroon",blue:"orange",orange:"blue",green:"violet",violet:"green",neutral:"maroon"};
const COUNT={sequential:{min:3,max:9},continuous:{min:3,max:11},categorical:{min:3,max:10},diverging:{set:[5,7,9,11]}};

function sourceColor(){if(state.mode==="bases")return GCPS_BASE[state.baseKey];if(state.mode==="clusters")return CLUSTERS[state.cluster];return CLUSTERS[SCHOOL_CLUSTER[state.school]];}
function sourceName(){if(state.mode==="bases")return cap(state.baseKey);if(state.mode==="clusters")return state.cluster;return state.school+" · "+SCHOOL_CLUSTER[state.school];}
function divergeOther(){if(state.mode==="bases")return GCPS_BASE[DIVERGE_PAIR_[state.baseKey]];const [L,C,H]=T.hexToOklch(sourceColor());return T.oklchToHex(L,C,(H+180)%360);}
function catMax(){return state.catSet==="clusters"?CLUSTER_ORDER.length:COUNT.categorical.max;}
function currentPalette(){
  const hex=sourceColor();
  switch(state.type){
    case"sequential":return T.sequential(hex,state.counts.sequential);
    case"tints":return T.tints(hex);
    case"diverging":return T.diverging(hex,divergeOther(),state.counts.diverging);
    case"continuous":return T.continuous(hex,state.counts.continuous);
    case"trend":return T.trend();
    case"performance":return state.perfV==="semantic"?T.perfSemantic(state.perfN):T.perfBase(hex,state.perfN);
    case"categorical":return T.categorical(state.catSet,Math.min(state.counts.categorical,catMax()));
  }
}
function accentHex(){const o=T.accentOptions().find(a=>a.id===state.accent);return o?o.hex:"#660000";}
function fontDef(){return T.FONTS.find(f=>f.id===state.font);}
function surf(){return T.SURFACES[state.surface];}

/* ---------- TAB: palette ---------- */
function renderSource(){
  const body=$("#srcBody");
  $$("#srcSeg button").forEach(b=>b.setAttribute('aria-pressed',b.dataset.m===state.mode));
  if(state.mode==="bases"){
    body.innerHTML='<div class="chip-row" id="chips"></div>';const row=body.querySelector('#chips');
    BASE_ORDER.forEach(k=>{const b=document.createElement('button');b.className='chip';b.setAttribute('aria-pressed',k===state.baseKey);b.innerHTML=`<span class="dot" style="background:${GCPS_BASE[k]}"></span><span class="nm">${k}</span>`;b.onclick=()=>{state.baseKey=k;render();};row.appendChild(b);});
  }else if(state.mode==="clusters"){
    body.innerHTML='<div class="chip-row" id="chips"></div>';const row=body.querySelector('#chips');
    CLUSTER_ORDER.forEach(k=>{const b=document.createElement('button');b.className='chip';b.setAttribute('aria-pressed',k===state.cluster);b.innerHTML=`<span class="dot" style="background:${CLUSTERS[k]}"></span><span class="nm" style="text-transform:none">${k}</span>`;b.onclick=()=>{state.cluster=k;render();};row.appendChild(b);});
  }else{
    body.innerHTML='<div class="row"><select id="schoolSel"></select><span class="school-resolved" id="schoolRes"></span></div>';
    const sel=body.querySelector('#schoolSel');
    SCHOOL_ORDER.forEach(s=>{const o=document.createElement('option');o.value=s;o.textContent=s;if(s===state.school)o.selected=true;sel.appendChild(o);});
    sel.onchange=()=>{state.school=sel.value;render();};
    const cl=SCHOOL_CLUSTER[state.school];
    body.querySelector('#schoolRes').innerHTML=`<span class="dot" style="background:${CLUSTERS[cl]}"></span>Inherits <b>${cl}</b> · ${CLUSTERS[cl]}`;
  }
}
const isGrid=()=>["continuous","tints","categorical"].includes(state.type);
function gridCols(){if(state.type==="tints")return 11;if(state.type==="continuous")return Math.min(state.counts.continuous,11);if(state.type==="categorical")return Math.min(Math.min(state.counts.categorical,catMax()),7);return 7;}
function semLabel(item,i,len){
  if(item.sem!==undefined)return item.sem;
  if(["sequential","tints","continuous"].includes(state.type)){if(i===0)return"Lightest";if(i===len-1)return"Darkest";if(i===Math.floor(len/2))return"Mid";return"";}
  if(state.type==="diverging"){if(i===Math.floor(len/2))return"Center";return item.n<0?"Low pole":"High pole";}
  return"";
}
function renderCount(){
  const wrap=$("#countWidget");
  if(state.type==="diverging"){
    wrap.innerHTML='<div class="seg" id="divSeg"></div>';const seg=wrap.querySelector('#divSeg');
    COUNT.diverging.set.forEach(v=>{const b=document.createElement('button');b.textContent=v;b.setAttribute('aria-pressed',v===state.counts.diverging);b.onclick=()=>{state.counts.diverging=v;render();};seg.appendChild(b);});return;
  }
  const cfg=COUNT[state.type];if(!cfg)return;
  const max=state.type==="categorical"?catMax():cfg.max;
  let v=clamp(state.counts[state.type],cfg.min,max);state.counts[state.type]=v;
  wrap.innerHTML=`<div class="stepper"><button id="cMinus">−</button><span class="val">${v} color${v>1?'s':''}</span><button id="cPlus">+</button></div><span class="mono" style="font-size:11px;color:var(--text-3)">${cfg.min}–${max}</span>`;
  const minus=wrap.querySelector('#cMinus'),plus=wrap.querySelector('#cPlus');
  minus.disabled=v<=cfg.min;plus.disabled=v>=max;
  minus.onclick=()=>{state.counts[state.type]=v-1;render();};plus.onclick=()=>{state.counts[state.type]=v+1;render();};
}
function renderPalette(){
  renderSource();
  $$("#typeSeg button").forEach(b=>b.setAttribute('aria-pressed',b.dataset.t===state.type));
  $("#perfCtrls").classList.toggle('show',state.type==="performance");
  $("#catCtrls").classList.toggle('show',state.type==="categorical");
  const hasCount=["sequential","continuous","categorical","diverging"].includes(state.type);
  $("#countCtrls").classList.toggle('show',hasCount);if(hasCount)renderCount();
  $$("#catSetSeg button").forEach(b=>b.setAttribute('aria-pressed',b.dataset.s===state.catSet));

  $("#dTitle").textContent=(TYPES.find(t=>t[0]===state.type)[1])+" · "+sourceName();
  let purpose=PURPOSE[state.type];
  if(state.type==="categorical")purpose=T.CAT_SETS[state.catSet].desc+(state.catSet==="clusters"?" Swatches are labeled with the cluster name.":"");
  $("#dPurpose").textContent=purpose;

  const pal=currentPalette();
  const ramp=document.createElement('div');
  ramp.className=state.type==="trend"?"trend-row":(isGrid()?"ramp gridwrap":"ramp");
  if(isGrid())ramp.style.setProperty('--cols',gridCols());
  ramp.innerHTML=pal.map((item,i)=>{
    const sem=semLabel(item,i,pal.length);
    const num=(state.type==="performance")?("L"+item.n):(state.type==="diverging"?(item.n>0?"+"+item.n:item.n):item.n);
    return `<div class="sw" data-hex="${item.hex}"><div class="swatch" style="background:${item.hex}"><span class="cp">Copy</span></div><div class="lbl"><div class="num">${num}</div>${sem?`<div class="sem">${sem}</div>`:''}<div class="hex">${item.hex}</div></div></div>`;
  }).join('');
  const host=$("#dRamp");host.innerHTML='';host.appendChild(ramp);
  ramp.querySelectorAll('.sw').forEach(sw=>sw.onclick=()=>copy(sw.dataset.hex,'Copied '+sw.dataset.hex));

  const aa=pal.filter(p=>T.contrastWhite(p.hex)>=4.5).length;
  const extra=state.type==="categorical"?` · ${T.CAT_SETS[state.catSet].label}`:"";
  $("#dMeta").textContent=`${pal.length} stops · ${aa} meet AA on white · source ${sourceColor()}${extra}`;
}

/* ---------- TAB: typography ---------- */
function renderType(){
  const grid=$("#fontGrid");grid.innerHTML='';
  T.FONTS.forEach(f=>{const b=document.createElement('button');b.className='fontcard';b.setAttribute('aria-pressed',f.id===state.font);b.innerHTML=`<span class="fn" style="font-family:${f.stack}">${f.label}</span><span class="fu">${f.use}</span>`;b.onclick=()=>{state.font=f.id;render();};grid.appendChild(b);});
  // ratio seg
  const rs=$("#ratioSeg");if(!rs.dataset.built){Object.entries(T.SCALE_RATIOS).forEach(([k,lbl])=>{const b=document.createElement('button');b.dataset.r=k;b.textContent=lbl;b.onclick=()=>{state.ratio=k;render();};rs.appendChild(b);});rs.dataset.built="1";}
  $$("#ratioSeg button").forEach(b=>b.setAttribute('aria-pressed',b.dataset.r===state.ratio));
  $$("#weightSeg button").forEach(b=>b.setAttribute('aria-pressed',+b.dataset.w===state.weight));
  $("#baseVal").textContent=state.baseSize+"px";
  const sc=T.typeScale(state.baseSize,state.ratio);
  const fam=fontDef().stack;
  const rows=[
    ["display",sc.display,state.weight,"-0.022em"],
    ["h1 · title",sc.h1,state.weight,"-0.018em"],
    ["h2 · section",sc.h2,state.weight,"-0.01em"],
    ["h3 · card",sc.h3,state.weight,"0"],
    ["body-lg",sc.bodyLg,400,"0"],
    ["body",sc.body,400,"0"],
    ["caption",sc.caption,600,"0.12em",true],
    ["micro",sc.micro,500,"0.04em"]
  ];
  const sample={ "display":"District Snapshot","h1 · title":"Palette Explorer","h2 · section":"Related palettes","h3 · card":"Teal — Sequential","body-lg":"Orientation copy that sits above a control group.","body":"Default UI text, table cells, field labels and helper sentences.","caption":"Typography Controls","micro":"#007C91 · contrast 4.8:1 AA"};
  $("#specimen").innerHTML=rows.map(([name,size,w,ls,upper])=>{
    const style=`font-family:${name==='micro'?'var(--mono)':fam};font-size:${size}px;line-height:1.2;font-weight:${w};letter-spacing:${ls};${upper?'text-transform:uppercase;color:var(--text-3);':''}`;
    return `<div class="type-row"><div class="meta"><b>${name}</b>${size}px · ${w}${ls!=='0'?'<br>'+ls:''}</div><div class="specimen" style="${style}">${sample[name]}</div></div>`;
  }).join('');
}

/* ---------- TAB: surfaces ---------- */
function renderSurfaces(){
  const grid=$("#surfGrid");grid.innerHTML='';
  Object.entries(T.SURFACES).forEach(([k,s])=>{
    const b=document.createElement('button');b.className='surf-card';b.setAttribute('aria-pressed',k===state.surface);
    b.innerHTML=`<div class="surf-prev"><span style="background:${s.canvas}"></span><span style="background:${s.surface}"></span><span style="background:${s.sunken}"></span><span style="background:${s.border}"></span><span style="background:${s.text}"></span></div><div class="surf-meta"><div class="sn">${s.label}</div><div class="snote">${s.note}</div></div>`;
    b.onclick=()=>{state.surface=k;render();};grid.appendChild(b);
  });
  const s=surf();
  const toks=[["canvas",s.canvas],["surface",s.surface],["sunken",s.sunken],["border",s.border],["border-strong",s.borderStrong],["text",s.text],["text-2",s.text2],["text-3",s.text3],["accent",accentHex()]];
  $("#tokenGrid").innerHTML=toks.map(([r,h])=>`<div class="token"><div class="chip" style="background:${h}"></div><div class="tb"><div class="role">${r}</div><div class="hx">${h.toUpperCase()}</div></div></div>`).join('');
  const ar=$("#accentRow");ar.innerHTML='';
  T.accentOptions().forEach(a=>{const b=document.createElement('button');b.className='chip';b.setAttribute('aria-pressed',a.id===state.accent);b.innerHTML=`<span class="dot" style="background:${a.hex}"></span><span class="nm" style="text-transform:none">${a.label}</span>`;b.onclick=()=>{state.accent=a.id;render();};ar.appendChild(b);});
  const SP=[["--s1","4px"],["--s2","8px"],["--s3","12px"],["--s4","16px"],["--s5","24px"],["--s6","32px"],["--s7","48px"],["--s8","64px"]];
  $("#spaceScale").innerHTML=SP.map(([n,v])=>`<div class="space-row"><span class="name">${n}</span><span class="val">${v}</span><div class="bar" style="width:${v}"></div></div>`).join('');
}

/* ---------- TAB: theme preview ---------- */
function renderPreview(){
  const s=surf();const acc=accentHex();const fam=fontDef().stack;
  const ramp=T.sequential(sourceColor(),5).map(x=>x.hex);
  const scope=$("#tpScope");
  scope.style.cssText=`--pv-canvas:${s.canvas};--pv-surface:${s.surface};--pv-border:${s.border};--pv-text:${s.text};--pv-text2:${s.text2};--pv-text3:${s.text3};--pv-accent:${acc};--pv-rampmid:${ramp[2]};--pv-font:${fam};`;
  const bars=[62,70,78,88,100].map((h,i)=>`<div class="b" style="height:${h}%;background:${ramp[i]}"></div>`).join('');
  const years=["2024–25","2023–24","2022–23","2021–22","2020–21"];const vals=["41.8%","40.4%","39.1%","37.8%","36.2%"];
  const legend=years.map((y,i)=>`<div class="tp-lg"><span class="dot" style="background:${ramp[4-i]}"></span> ${y} · ${vals[i]}</div>`).join('');
  scope.innerHTML=`
    <div class="tp-bar"><div class="mk"></div><div class="tt">GCPS <span>District Snapshot</span></div></div>
    <div class="tp-body">
      <div class="tp-orient">Live preview · ${sourceName()} ramp · ${fontDef().label} ${state.baseSize}px · synthetic K-12 data</div>
      <div class="tp-kpis">
        <div class="tp-kpi"><div class="k">Enrollment</div><div class="v">82,453</div><div class="d">▲ 1.2%</div></div>
        <div class="tp-kpi"><div class="k">Schools</div><div class="v">142</div><div class="d" style="color:var(--pv-text3)">—</div></div>
        <div class="tp-kpi"><div class="k">% P / D</div><div class="v">41.8</div><div class="d">▲ 1.4%</div></div>
        <div class="tp-kpi"><div class="k">Grad rate</div><div class="v">82.6</div><div class="d">▲ 1.6%</div></div>
      </div>
      <div class="tp-row">
        <div class="tp-card"><div class="ch">% Proficient / Distinguished — 5-year trend</div><div class="tp-bars">${bars}</div></div>
        <div class="tp-card"><div class="ch">Legend</div><div class="tp-legend">${legend}</div><a class="tp-btn">View report →</a></div>
      </div>
    </div>`;
}

/* ---------- TAB: accessibility ---------- */
function a11yCard(fg,bg,pair){
  const r=T.contrast(fg,bg);const rt=T.rating(r,false);
  return `<div class="a11y"><div class="demo" style="background:${bg};color:${fg}">Aa</div><div class="ab"><div class="meta"><div class="pair">${pair}</div><div class="ratio">${r.toFixed(2)}:1</div></div><span class="badge ${rt}">${rt==='AA-lg'?'AA Large':rt.toUpperCase()}</span></div></div>`;
}
function renderA11y(){
  const s=surf();const acc=accentHex();
  $("#a11yChrome").innerHTML=[
    a11yCard(s.text,s.surface,"text on surface"),
    a11yCard(s.text2,s.surface,"text-2 on surface"),
    a11yCard(s.text3,s.surface,"text-3 on surface"),
    a11yCard(s.text,s.canvas,"text on canvas"),
    a11yCard(acc,s.surface,"accent on surface"),
    a11yCard("#FFFFFF",acc,"white on accent")
  ].join('');
  const pal=currentPalette();
  $("#a11yPalette").innerHTML=pal.map(p=>a11yCard(p.hex,"#FFFFFF",(p.sem||("Stop "+p.n))+" on white")).join('');
}

/* ---------- TAB: export ---------- */
function slug(){return `${sourceName().toLowerCase().replace(/[^a-z0-9]+/g,'_').replace(/^_|_$/g,'')}_${state.type}`;}
function buildExport(){
  const s=surf();const acc=accentHex();const f=fontDef();const sc=T.typeScale(state.baseSize,state.ratio);
  const pal=currentPalette();const hexes=pal.map(p=>p.hex);const sg=slug();
  const gradient=["sequential","continuous","tints","diverging"].includes(state.type);
  const hasSem=pal.some(p=>p.sem);
  if(state.exp==="css"){
    $("#expFile").textContent="gcps_theme.css";
    return `:root{\n`+
`  /* surfaces */\n  --canvas:${s.canvas};\n  --surface:${s.surface};\n  --sunken:${s.sunken};\n  --border:${s.border};\n  --border-strong:${s.borderStrong};\n`+
`  /* text */\n  --text:${s.text};\n  --text-2:${s.text2};\n  --text-3:${s.text3};\n`+
`  /* accent */\n  --accent:${acc};\n  --accent-hover:${T.accentHover(acc)};\n  --accent-tint:${T.accentTint(acc)};\n`+
`  /* type */\n  --font-sans:${f.stack};\n  --fs-display:${sc.display}px; --fs-h1:${sc.h1}px; --fs-h2:${sc.h2}px; --fs-h3:${sc.h3}px;\n  --fs-body-lg:${sc.bodyLg}px; --fs-body:${sc.body}px; --fs-caption:${sc.caption}px; --fs-micro:${sc.micro}px;\n`+
`  /* spacing & radius */\n  --s1:4px; --s2:8px; --s3:12px; --s4:16px; --s5:24px; --s6:32px; --s7:48px; --s8:64px;\n  --r-sm:6px; --r-md:10px; --r-lg:14px;\n`+
`  /* data palette · ${sourceName()} ${state.type} */\n`+hexes.map((h,i)=>`  --gcps-${sg}-${typeof pal[i].n==='number'?pal[i].n:i+1}: ${h};`).join('\n')+`\n}`;
  }
  if(state.exp==="json"){
    $("#expFile").textContent="gcps_theme.json";
    const theme={name:`GCPS ${sourceName()} — ${state.type}`,dataColors:hexes,background:s.canvas,foreground:s.text,tableAccent:acc,
      textClasses:{label:{fontFace:f.label,color:s.text2},title:{fontFace:f.label,color:s.text},callout:{fontFace:f.label,color:s.text}}};
    return JSON.stringify(theme,null,2);
  }
  // R
  $("#expFile").textContent="gcps_theme.R";
  let out=`# GCPS ${sourceName()} theme — generated by GCPS Theme Studio\nlibrary(ggplot2)\n\n`;
  out+=`gcps_tokens <- list(\n  canvas = "${s.canvas}", surface = "${s.surface}", sunken = "${s.sunken}",\n  border = "${s.border}", text = "${s.text}", text_muted = "${s.text2}", accent = "${acc}"\n)\n\n`;
  if(hasSem){out+=`${sg} <- c(\n`+pal.map(p=>`  "${p.sem}" = "${p.hex}"`).join(",\n")+`\n)\n`;}
  else{out+=`${sg} <- c(${hexes.map(h=>`"${h}"`).join(", ")})\n`;}
  out+=`\n`;
  if(gradient){
    out+=`scale_fill_gcps  <- function(...) scale_fill_gradientn(colours = ${sg}, ...)\n`;
    out+=`scale_color_gcps <- function(...) scale_color_gradientn(colours = ${sg}, ...)\n\n`;
  }else{
    out+=`scale_fill_gcps  <- function(...) scale_fill_manual(values = ${sg}, ...)\n`;
    out+=`scale_color_gcps <- function(...) scale_color_manual(values = ${sg}, ...)\n\n`;
  }
  out+=`theme_gcps <- function(base_size = ${state.baseSize}, base_family = "${f.label}") {\n`+
`  theme_minimal(base_size = base_size, base_family = base_family) +\n`+
`    theme(\n`+
`      plot.background  = element_rect(fill = gcps_tokens$canvas, colour = NA),\n`+
`      panel.background = element_rect(fill = gcps_tokens$surface, colour = NA),\n`+
`      panel.grid.minor = element_blank(),\n`+
`      panel.grid.major = element_line(colour = gcps_tokens$border),\n`+
`      text             = element_text(colour = gcps_tokens$text),\n`+
`      plot.title       = element_text(face = "bold", colour = gcps_tokens$text),\n`+
`      axis.text        = element_text(colour = gcps_tokens$text_muted)\n`+
`    )\n}`;
  return out;
}
function renderExport(){
  $$("#expSeg button").forEach(b=>b.setAttribute('aria-pressed',b.dataset.f===state.exp));
  $("#expCode").textContent=buildExport();
}

/* ---------- topbar ---------- */
function renderPill(){
  const acc=T.accentOptions().find(a=>a.id===state.accent);
  $("#themePill").textContent=`${acc.label} · ${fontDef().label} · ${state.baseSize}px`;
}

/* ---------- master ---------- */
function render(){
  renderPill();
  switch(state.tab){
    case"palette":renderPalette();break;
    case"type":renderType();break;
    case"surfaces":renderSurfaces();break;
    case"preview":renderPreview();break;
    case"a11y":renderA11y();break;
    case"export":renderExport();break;
  }

  // --- bridge to Shiny (no-op outside Shiny) ---
  // Pushes the CURRENT studio theme into input$ts_theme on every change so the
  // R side (Project Templates, build_config()) can bake it into exports.
  if (window.Shiny && Shiny.setInputValue) {
    const s = surf(); const acc = accentHex(); const f = fontDef();
    const sc = T.typeScale(state.baseSize, state.ratio);
    const pal = currentPalette();
    Shiny.setInputValue('ts_theme', {
      source:   sourceName(),
      type:     state.type,
      // surfaces
      canvas: s.canvas, surface: s.surface, sunken: s.sunken,
      border: s.border, border_strong: s.borderStrong,
      text: s.text, text_2: s.text2, text_3: s.text3, dark: !!s.dark,
      // accent
      accent: acc, accent_hover: T.accentHover(acc), accent_tint: T.accentTint(acc),
      // typography
      font_label: f.label, font_stack: f.stack, font_google: f.google || "",
      base_size: state.baseSize, ratio: state.ratio, heading_weight: state.weight,
      scale: sc,                                  // {micro,caption,body,bodyLg,h3,h2,h1,display}
      // data palette (current type) — names present for categorical/performance/trend
      palette: pal.map(p => ({ n: p.n, hex: p.hex, name: (p.sem || null) })),
      palette_hex: pal.map(p => p.hex)
    }, { priority: 'event' });
  }
}
function setTab(t){
  state.tab=t;
  $$("#tabs .tab").forEach(b=>b.setAttribute('aria-selected',b.dataset.tab===t));
  $$(".panel-tab").forEach(p=>p.classList.toggle('active',p.id==="tab-"+t));
  render();
}

/* ---------- toast/copy ---------- */
let tt;function copy(text,msg){const f=()=>{const el=$("#toast");el.textContent=msg;el.classList.add('show');clearTimeout(tt);tt=setTimeout(()=>el.classList.remove('show'),1400);};if(navigator.clipboard&&navigator.clipboard.writeText){navigator.clipboard.writeText(text).then(f,f);}else f();}

/* ---------- wire ---------- */
$$("#tabs .tab").forEach(b=>b.onclick=()=>setTab(b.dataset.tab));
$$("#srcSeg button").forEach(b=>b.onclick=()=>{state.mode=b.dataset.m;render();});
TYPES.forEach(([id,lbl])=>{const b=document.createElement('button');b.dataset.t=id;b.textContent=lbl;b.onclick=()=>{state.type=id;render();};$("#typeSeg").appendChild(b);});
Object.entries(T.CAT_SETS).forEach(([k,v])=>{const b=document.createElement('button');b.dataset.s=k;b.textContent=v.label;b.onclick=()=>{state.catSet=k;render();};$("#catSetSeg").appendChild(b);});
$("#semToggle").onchange=e=>document.querySelector('.ts-root').classList.toggle('semantic',e.target.checked);
$$("#perfLevels button").forEach(b=>b.onclick=()=>{state.perfN=+b.dataset.n;render();});
$$("#perfVariant button").forEach(b=>b.onclick=()=>{state.perfV=b.dataset.v;render();});
$("#baseSize").oninput=e=>{state.baseSize=parseFloat(e.target.value);render();};
$$("#weightSeg button").forEach(b=>b.onclick=()=>{state.weight=+b.dataset.w;render();});
$$("#expSeg button").forEach(b=>b.onclick=()=>{state.exp=b.dataset.f;renderExport();});
$("#expCopy").onclick=()=>copy($("#expCode").textContent,'Theme export copied');

setTab("palette");
})();
