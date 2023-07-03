import 'package:poker/demo/demo_adapter.dart';

class DemoHelper {
  DemoHelper._();

  static List<DemoData> data() {
    List<String> pics = DemoHelper._stars + DemoHelper._nights + DemoHelper._scenery + DemoHelper._relaxed;
    // List<String> pics = DemoHelper._stars;
    pics.shuffle();
    _name.shuffle();
    List<DemoData> data = [];
    for (int i = 0; i < pics.length; i++) {
      data.add(DemoData(id: i, name: _name[i % _name.length], url: pics[i]));
    }
    return data;
  }

  static final List<String> _name = [
    'Marco Chen',
    'Deacon Zhao',
    'Nash Chen',
    'Mira Mao',
    'Baylee Zhang',
    'Brenden Li',
    'Barry Huang',
    'Vick Qi',
    'Kiley Kong',
    'Britany Du',
    'Chelsea Yang',
    'Jessa Yan',
    'Melisa Deng',
    'Alma Liu',
    'Harris Wang',
    'Toby Li',
    'Chance Li',
    'Caitlyn Xin',
    'Jessa Zhu',
    'Alysia Wu',
  ];
  static final List<String> _stars = [
    'https://hbimg.huabanimg.com/6d3cc986621ab853d3834ed47aa9609f24f1b4b8318b28-QTIb9i_fw1200',
    'https://hbimg.huabanimg.com/931ac4833cc3e6837bd1c1704a5198db8c536af162282-xE7EgQ_fw1200',
    'https://hbimg.huabanimg.com/6d3086666fcf92a27b54f994517ec83b28562f047dea7-NwjxwK_fw1200',
    'https://hbimg.huabanimg.com/424ecb1062ac1def81e7832d7a2246055d556436838f7-zFFuWJ_fw1200',
    'https://hbimg.huabanimg.com/0360fd54e1d02151e796c452981655b211ed3e6a7b1bd-RnoRFw_fw1200',
    'https://hbimg.huabanimg.com/0407a93eeac26cf48407004d001e819f400e73502c9cf0-nuAsix_fw1200',
    'https://hbimg.huabanimg.com/5ed2a8803fe36b6a53e46aa079a4a0cdbde3fb35296a56-xoxmCF_fw1200',
    'https://hbimg.huabanimg.com/aed6ac581c88fcf63c7d3ae97bda7b3717e2aeaa6859b-GYqixk_fw1200'
  ];

  static final List<String> _nights = [
    'https://hbimg.huabanimg.com/9601229034342adcb11b3ba6fd742f834a0ad0bf530f9-UxsWYi_fw1200',
    'https://hbimg.huabanimg.com/9683e57bf6777090f642bcbdfddc177a4ddec2ff5e761-lWBo16_fw1200',
    'https://hbimg.huabanimg.com/06007201fccc6beb27a15277121a7b4894428a315a78b-3tbt8P_fw1200',
    'https://hbimg.huabanimg.com/26ac1e63543ce0da7f54e7703fe13d02994c6f5694679-YGn8mI',
    'https://hbimg.huabanimg.com/2ae34c2174d18e84a545928e21b071268c8a09266b555-HkENn6_fw1200',
    'https://hbimg.huabanimg.com/5694b62a2e4766aa4618c8e64ce6c3d32b804301bda09-EcEzrx',
    'https://hbimg.huabanimg.com/a43e24c9f626c24b4a895aa160fc130bfa8573e57a36d-mpwbIS_fw1200',
    'https://hbimg.huabanimg.com/ae6f1a68182b2872cce7aa68ffc27a292bdc83d314013f-AyrGLl_fw1200',
    'https://hbimg.huabanimg.com/7f2d475cc8cf673df985c5e3854667df65bd0bdf50ce1-HygsPh_fw1200',
  ];

  static final List<String> _scenery = [
    'https://hbimg.huabanimg.com/2428f5f77ad4f7b15b02d44b436b512658dd80da13109-s1EqCC',
    'https://hbimg.huabanimg.com/86d08f806e55b39be42339037097fbd51781006966dd0-mPiUQo',
    'https://hbimg.huabanimg.com/1464e0d3957bdc51680ab5dfe4ee2d0ef23c9622db218-LgirYZ',
    'https://hbimg.huabanimg.com/9a2a7705b32dd228dbe3fff83c78484add35a036672ef-BxO3O4',
    'https://hbimg.huabanimg.com/f91d8e83d42ab4cdc9d7aa7a9618148ab0cf91894d0e7-cWs8zF',
    'https://hbimg.huabanimg.com/b6d8be760ebbaf94f1b21e08227ccc48f10c9a912ffce-nISUYi',
    'https://hbimg.huabanimg.com/7704985f38ca2885cdc7027e8929718167f030721f9b3-JvXuBa',
    'https://hbimg.huabanimg.com/954787a093ff91da572040178b4e83238c5c1431b333a-8UO6QZ',
    'https://hbimg.huabanimg.com/606e357df71c41bc9e9a7b4d16518265da20b7461a780-m1aipn',
    'https://hbimg.huabanimg.com/971ba35612afb96bb2755e2a39d558bd10ba47ef2c5f2-Wi8Y0I',
    'https://hbimg.huabanimg.com/c3972b96722ce5f546e1d5a2eb6b4a22655281f933c5b-2bVgPY',
    'https://hbimg.huabanimg.com/296aa0bac4083e3690900ab6d35609f09e6afaec16aec5-uJm4mX',
    'https://hbimg.huabanimg.com/967afef709a750cb5d742d2346db8fe4eac157cae1b89-Jvl51U',
    'https://hbimg.huabanimg.com/0f7165e20a396df3f5eec475f36b1f34af09ec8db148f-Jx6DAs',
    'https://hbimg.huabanimg.com/f5039e63748a72c479633f9fc5e071618dedb52049afc-8NcL9X',
    'https://hbimg.huabanimg.com/ca6693af7e0d9f8e120d43679cff66df0b6f2fde9c924-40IWuB',
    'https://hbimg.huabanimg.com/01482c267a7702d424bb78245ec0e732ed68cd337ae33-qm9Yn9',
    'https://hbimg.huabanimg.com/0aca073088ba942bebc9f79be8098cad14a95bff3068e-23regA',
    'https://hbimg.huabanimg.com/792d7bc7a9db2f754d454fd181d128338771f6b0473e4-wdbKwu',
    'https://hbimg.huabanimg.com/d7275b76dc34e19028db9d7e4cf1623086591cb836351-IVsofG',
    'https://hbimg.huabanimg.com/d2ff5e636d18c6322bd947aec43cc62a6a904eb23964d-F29Tpt',
    'https://hbimg.huabanimg.com/0561ddfa84f04676691f592ec8a4df6a77be5f7ba0a97-qGcb9s',
    'https://hbimg.huabanimg.com/a88011d10550d1e7b8f150c76a589de5a3b110652ca1a-Tb8xQV',
    'https://hbimg.huabanimg.com/3aaedeccb3745aed8f0568cc56ea7f7c1631d7d76aacd-ZgyQ5b',
    'https://hbimg.huabanimg.com/fe785aa2dd6310b4788bb6aa1ef9c1af90e7ba202f07d-KccoOL',
    'https://hbimg.huabanimg.com/3a20ba1f4cf71bda0d9dabd8479008320089f2bc64ac6-lvnbhn',
    'https://hbimg.huabanimg.com/90edbc2d906284cd0b1a10ed55c2abef6a362729746f8-a7htur',
    'https://hbimg.huabanimg.com/913abdd544851d970b442fd0437a633c1b41fc83229a7-iq3rjA',
    'https://hbimg.huabanimg.com/c62f7ff2eb16e5b7b5d28128891e75dab8ab2f0e38792-AbcmBi',
    'https://hbimg.huabanimg.com/dfa8cf332a39a2c986fd7e60122f30053536886d49b0d-RNeigL',
    'https://hbimg.huabanimg.com/baad66f6cf54448a963d4b15e2b7cd8cab39688756686-ArS0t1',
    'https://hbimg.huabanimg.com/0a39d861163460951e9e808b6c03f069ad82e67b487b0-IHBGGV',
    'https://hbimg.huabanimg.com/e6762840e8ddbe594d38e607af4dc648aaff637e2f074-PkRUzx',
    'https://hbimg.huabanimg.com/8575600ba674cfd6e6bdacf7fe9962e4c738d589540f1-vnXniW',
    'https://hbimg.huabanimg.com/7e7861f7efacb07689152a9d60a4abfae930ec9f5dc90-ElxNcU',
    'https://hbimg.huabanimg.com/74b0223f96f8c22cc466d0037f59f91c2f5ae760c668e-F5eDGH',
    'https://hbimg.huabanimg.com/20e14ca5a173cd565afdb058c69baa52e98b4869d0580-zASW4U',
    'https://hbimg.huabanimg.com/2a0fc9d2a060064d2e2f5035335812f7e90d9f2f7c14f-U6G5rS',
    'https://hbimg.huabanimg.com/7bebd034af56d6b28147984a36366b8b4428a40dc1d2a-hKGzAt',
    'https://hbimg.huabanimg.com/29f6b9a163cfb82e80f0dd03f3c88f7fd16fa7d73eae5-lwz7mE',
    'https://hbimg.huabanimg.com/e0f1e09eafb2195ba8d9d6347bb7b981aea6c321370c0-RPxc2Y',
    'https://hbimg.huabanimg.com/94db766e7722df4b51aad0af916e8fdbb2055ae220626-ChbPfe',
    'https://hbimg.huabanimg.com/d242c2876e8f47a18cd6d7a6d537fcd5eacf3f4bba636-v4xaKd',
    'https://hbimg.huabanimg.com/144f0eca21bd9490d5b0434aeef5d732dce80fc02060f9-V4m7oQ',
    'https://hbimg.huabanimg.com/5f498596fb273ab981e5fa6a7ae5e913fe945ca223dc9f-4s50Gj',
    'https://hbimg.huabanimg.com/7c8977bdeb1fa3e4b412a48e5285df910eaa2b3e1db850-npVRxy',
    'https://hbimg.huabanimg.com/0d733532fc92d019a35f3cd7b8102cb8f245f8f63ba88-mM5iIA',
    'https://hbimg.huabanimg.com/52728f428aee5531aece80c90aa49e6319668b0ffff73-QkpaM8',
    'https://hbimg.huabanimg.com/599dbb7f6faa3214d27bfc2005ea9f70e527b62960398-yQcogv',
    'https://hbimg.huabanimg.com/6857e4ce250f903969fb75313de356a50a36ba5b14aeac-jW2FyZ',
    'https://hbimg.huabanimg.com/4b9bd5cbb87ee76602e8a0caadb523fb5ceb88f767d4f-PruI2r',
    'https://hbimg.huabanimg.com/e8119cf432402011cb62ef1bce2ca904852e53cb3d483-ehX29Y',
    'https://hbimg.huabanimg.com/4df213e803e311ea62769b058dfd9ee16f02a95a6666b-7JEhBX',
    'https://hbimg.huabanimg.com/4753ffdd2f5604232c7d40f67798e488eb8e4d6cddeed-TVcsQl',
  ];

  static final List<String> _relaxed = [
    'https://gd-hbimg.huaban.com/4264b59610af5988b88750aeab3776f6fbe7d3fc4af19-HvmZgX_fw1200webp',
    'https://gd-hbimg.huaban.com/ce887ae3bdfac2f1d7e5151dd31204b51c02b64d6e0fd-Zr6jUA_fw1200webp',
    'https://gd-hbimg.huaban.com/f17458109003e6d105f738d0a487e648a7d01c12a891f-KE3SdK_fw1200webp',
    'https://gd-hbimg.huaban.com/ce235cb6c86c6462941c0626463888c70b56c3c634f12-k5iS6p_fw1200webp',
    'https://gd-hbimg.huaban.com/2a6dbf9ce61f1978cc5b944e90dd2223630693b6ff61-3DZoTA_fw1200webp',
    'https://gd-hbimg.huaban.com/3ed1fd44f51798fee8c18a4cfb32df5407a54796811b7-8RvMtI_fw1200webp',
    'https://gd-hbimg.huaban.com/da3ed3f8da0168eb1f8c1b1d16666c79f914358b31250-8wLiy7_fw1200webp',
    'https://gd-hbimg.huaban.com/037bb65ec96730f5ef53628898060f042b0fa75c71ab7-9I10Ge_fw1200webp',
    'https://gd-hbimg.huaban.com/f62540ae14aee15fa5a34646f3901b4cad7cb8deca909-cq824B_fw1200webp',
    'https://gd-hbimg.huaban.com/ff83984e6660ed5eb264fa3eb62768631bc11ae83899ff-ctaIQY_fw1200webp',
    'https://gd-hbimg.huaban.com/de3f4a0263b11760836392d1dcd4d930eb9eec9b5ba206-2EN7OG_fw1200webp',
    'https://gd-hbimg.huaban.com/c81dcd09f2f0f7f4a322a2726703bb2bc6503712d16d9-mQeiBR_fw1200webp',
    'https://gd-hbimg.huaban.com/e6b75f0c3518442c4f960fbf8f9fe4f44971027b4d68f-rlNQRP_fw1200webp',
    'https://gd-hbimg.huaban.com/774fca6321bf1d2206b7010e89cd2f2dc4d36814192551-ewpX6r_fw1200webp',
    'https://gd-hbimg.huaban.com/ab25cb7be28695581e1cc4061239418feea7e7eba24b3-KYTHhe_fw1200webp',
    'https://gd-hbimg.huaban.com/5bc62c7f8d6347805a9299204b2c76d98074196334b94-i8i0gD_fw1200webp',
    'https://gd-hbimg.huaban.com/99b283b698c025735636ffbe8c7314622fee911324d42a-90niDk_fw1200webp',
    'https://gd-hbimg.huaban.com/16e022d010b242e583b811993cc80b9979036803274fe7-iC04Mt_fw1200webp',
    'https://gd-hbimg.huaban.com/fb95cb5b653671063c46059eef75ec6851dfd65b5ef43-9dFusw_fw1200webp',
    'https://gd-hbimg.huaban.com/6940a9fa8dd4e9ef0075e22b83d5c61ee91b0f1b250f6-zs0Kvo_fw1200webp',
  ];
}
