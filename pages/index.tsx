import Head from 'next/head'
import type { NextPage } from "next";
import { useRouter } from "next/router";
import styles from "../styles/Home.module.css";

const Home: NextPage = () => {
  const router = useRouter();

  return (
    <div className={styles.container}>
      <Head>
        <title>The ROTY BROI Staking</title>
        <meta charSet="utf-8" />
        <meta name="viewport" content="initial-scale=1.0, width=device-width" />
      </Head>
      {/* Top Section */}
      <h1 className={styles.h1}>The ROTY BROI Staking</h1>

      <hr className={`${styles.divider} ${styles.spacerTop}`} />

      <div className={styles.nftBoxGrid}>
        <div
          className={styles.optionSelectBox}
          role="button"
          onClick={() => router.push(`/stake`)}
        >
          {/* Staking The ROTY BROI */}
          <Image src={`/icons/rotybroi.webp`} alt="stake" />
          <h2 className={styles.selectBoxTitle}>The ROTY BROI NFTs Staking</h2>
          <p className={styles.selectBoxDescription}>
            Earn <b>OiOi tokens</b> by staking <b>The ROTY BROI</b> NFTs using{" "}
            <b>The ROTY BROI</b> staking smart contract.
          </p>
        </div>
      </div>
      <div className={styles.nftBoxGrid}>
        <div
          className={styles.optionSelectBox}
          role="button"
          onClick={() =>
            window.open(`https://opensea.io/collection/the-roty-broi`, `_blank`)
          }
        >
          {/* Buy The ROTY BROI */}
          <img src={`/icons/rotybroi.webp`} alt="market" />
          <h2 className={styles.selectBoxTitle}>Buy The ROTY BROI</h2>
          <p className={styles.selectBoxDescription}>
            Go to the biggest NFTs marketplace, <b>OpenSea.IO</b> to buy{" "}
            <b>The ROTY BROI</b> NFTs on <b>Polygon blockchain</b>.
          </p>
        </div>
        <div
          className={styles.optionSelectBox}
          role="button"
          onClick={() =>
            window.open(`https://rotybroi-rarity.vercel.app/`, `_blank`)
          }
        >
          {/* The ROTY BROI Rarity */}
          <img src={`/icons/rotybroi.webp`} alt="rarity" />
          <h2 className={styles.selectBoxTitle}>The ROTY BROI Rarity</h2>
          <p className={styles.selectBoxDescription}>
            Find the rarest character of <b>The ROTY BROI</b> using this rarity
            rank tools, the hidden gem exposer.
          </p>
        </div>
      </div>

      <hr className={`${styles.divider} ${styles.spacerTop}`} />

      <p
        className={styles.selectBoxProfNota}
        role="button"
        onClick={() => window.open(`https://twitter.com/myreceiptt`, `_blank`)}
      >
        by Prof. NOTA
      </p>
    </div>
  );
};

export default Home;
